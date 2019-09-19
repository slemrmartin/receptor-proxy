require 'socket'

class OrdersController < ApplicationController
  # GET
  def index
    payload = {
      'method'  => 'GET',
      'url'     => "http://localhost:3002/api/sources/v1.0/sources",
      'headers' => identity_headers(external_tenant)
    }
    response = send_directive("receptor_http:execute",
                              target_receptor,
                              payload.to_json)

    hash = JSON.parse(response)

    render :json => hash.dig('raw_payload', 'body'), :status => hash.dig('raw_payload', 'status')
  end

  # GET
  def source_update
    payload = {
      'method'  => 'PATCH',
      'url'     => "http://localhost:3002/api/sources/v1.0/sources/2",
      'data'    => {'name' => 'Openshift Changed'}.to_json,
      'headers' => identity_headers(external_tenant)
    }

    response = send_directive("receptor_http:execute",
                              target_receptor,
                              payload.to_json)

    hash = JSON.parse(response)

    render :json => hash.dig('raw_payload', 'body'), :status => hash.dig('raw_payload', 'status')
  end

  private

  def external_tenant
    '1460290'
  end

  # This name has to be in sources db
  def target_receptor
    "node-a"
  end
end
