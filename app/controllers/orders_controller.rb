require 'socket'

class OrdersController < ApplicationController
  SOCKET_PATH = "/tmp/receptor.sock".freeze
  DELIM = "\x1b[K".freeze

  def index
    target_receptor = "node-a" # This name has to be in sources db
    payload = {
      'method'  => 'GET',
      'url'     => "http://localhost:3002/api/sources/v1.0/sources",
      'headers' => identity_headers('1460290')
    }
    response = send_directive("receptor_http:execute",
                              target_receptor,
                              payload.to_json)

    hash = JSON.parse(response)

    render :plain => hash['raw_payload']['body']
  end

  private

  def send_directive(directive, recipient, payload, socket_path = SOCKET_PATH)
    socket = UNIXSocket.new(socket_path)
    socket.send("#{recipient}\n#{directive}\n#{payload}" + DELIM, 0)
    response = ''
    loop do
      received = socket.recv(1024)
      done = received.include?(DELIM)
      received.sub!(DELIM, '') if done

      response += received
      break if done
    end
    response
  ensure
    socket.close
  end

  def identity_headers(tenant)
    {
      "x-rh-identity" => Base64.strict_encode64(
        JSON.dump({"identity" => {"account_number" => tenant}})
      )
    }
  end
end
