require "active_support/inflector"
require "active_support/core_ext/string"
require "socket"
# require "surro-gate"
require "json"
require "pry-byebug"

module ReceptorProxy
  class Server
    SOCKET_PATH = "/tmp/receptor.sock".freeze
    DELIM       = "\x1b[K".freeze

    def initialize
      @source_uid = ENV['SOURCE_UID']
      @endpoint = {
        :scheme => ENV['ENDPOINT_SCHEME'] || 'https',
        :host   => ENV['ENDPOINT_HOST'],
        :receptor_node => ENV['ENDPOINT_RECEPTOR_NODE']
      }
      @auth = {
        :username => ENV['AUTH_USERNAME'],
        :password => ENV['AUTH_PASSWORD']
      }
    end

    def call(env)
      # Check source values
      if @endpoint.values.select(&:blank?) ||
         @auth.values.select(&:blank?)
        return not_found
      end

      base_url = if @endpoint[:host] =~ %r{\Ahttps?:\/\/} # HACK: URI can't properly parse a URL with no scheme
                   URI(File.join(@endpoint[:scheme], "://", @endpoint[:host]))
                 else
                   URI(@endpoint[:host])
                 end

      # Get all HTTP headers
      headers = {}
      env.select { |k, _v| k.start_with?('HTTP_') }.each do |key, val|
        new_key          = key.sub(/^HTTP_/, '')
        headers[new_key] = val
      end

      headers['HOST'] = base_url


      payload = {
        'method'  => env['REQUEST_METHOD'],
        'url'     => File.join(base_url, env['REQUEST_URI']),
        'headers' => headers,
        'ssl'     => false
      }

      response = send_directive("receptor_http:execute",
                                @endpoint[:receptor_node],
                                payload.to_json)

      hash = JSON.parse(response)

      # resp                         = Rack::Response.new
      # resp.headers['Content-Type'] = 'application/json'
      # resp.body                    = [hash['raw_payload']['body'].to_json]
      # resp.status                  = hash['raw_payload']['status']

      # Rack requires this line below
      # TODO: Get HTTP Response Headers from receptor
      return [hash['raw_payload']['status'],
              {'Content-Type' => 'application/json'},
              [hash['raw_payload']['body'].to_json]
      ]
    rescue => ex
      puts ex.message
      puts ex.backtrace
      return not_found # Return with a 404 error
    end

    protected

    def send_directive(directive, recipient, payload, socket_path = SOCKET_PATH)
      socket = UNIXSocket.new(socket_path)
      socket.send("#{recipient}\n#{directive}\n#{payload}" + DELIM, 0)
      response = ''
      loop do
        received = socket.recv(1024)
        done     = received.include?(DELIM)
        received.sub!(DELIM, '') if done

        response += received
        break if done
      end
      response
    ensure
      socket.close
    end

    def not_found
      [404, {'Content-Type' => 'text/plain'}, ['Not found!']]
    end

    def cleanup(*sockets)
      # Omit `nil`s from the array
      sockets.compact!
      # Close the opened sockets and remove them from the proxy
      sockets.each { |sock| sock.close unless sock.closed? }
      @proxy.pop(*sockets) if sockets.length > 1
    end
  end
end