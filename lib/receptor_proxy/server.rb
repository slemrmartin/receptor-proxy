require "active_support/inflector"
require "active_support/core_ext/string"
require "socket"
require "json"

module ReceptorProxy
  class Server
    SOCKET_PATH = "/tmp/receptor.sock".freeze
    DELIM       = "\x1b[K".freeze

    def initialize
      @mutex = Mutex.new
    end

    def call(env)
      base_url = CGI.unescape(env['HTTP_X_RH_ENDPOINT'])
      receptor_node_id = env['HTTP_X_RH_RECEPTOR']

      # Get all HTTP headers
      headers = {}
      env.select { |k, _v| k.start_with?('HTTP_') }.each do |key, val|
        next if %w[HTTP_X_RH_RECEPTOR HTTP_X_RH_ENDPOINT].include?(key)

        new_key = key.sub(/^HTTP_/, '').tr('_'.freeze, '-'.freeze)
        headers[new_key] = val
      end

      headers['HOST'] = base_url.to_s.gsub(/\Ahttps?:\/\//, '').split('/')[0]

      # URI + String removes URI path if String starts with '/'
      # This technique is used by Faraday client
      payload = {
        'method'  => env['REQUEST_METHOD'],
        'url'     => URI(base_url.to_s) + env['REQUEST_URI'].to_s,
        'headers' => headers,
        'ssl'     => false
      }

      response = send_directive("receptor_http:execute",
                                receptor_node_id,
                                payload.to_json,
                                SOCKET_PATH)
      hash = JSON.parse(response)

      resp                         = Rack::Response.new
      resp.headers['Content-Type'] = 'application/json'

      body = hash['raw_payload']
      if body.kind_of?(Hash)
        resp.body                    = [hash['raw_payload']['body']]
        resp.status                  = hash['raw_payload']['status']
      else
        resp.body = [hash['raw_payload']]
        resp.status = 502
      end

      # Rack requires this line below
      [resp.status, resp.headers, resp.body]
    rescue => ex
      puts ex.message
      puts ex.backtrace
      return not_found # Return with a 404 error
    end

    protected

    def send_directive(directive, recipient, payload, socket_path = SOCKET_PATH)
      socket = UNIXSocket.new(socket_path)

      @mutex.synchronize do
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
      end
    ensure
      socket.close
    end

    def not_found
      [404, {'Content-Type' => 'text/plain'}, ['Not found!']]
    end
  end
end
