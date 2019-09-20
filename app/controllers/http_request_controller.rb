class HttpRequestController < ApplicationController
  DIRECTIVE_NAME = "receptor_http:execute".freeze

  # POST /http_request
  def send
    response = send_directive(DIRECTIVE_NAME,
                              params_for_receptor[:receptor_name],
                              params_for_receptor[:payload])

    parsed_response = JSON.parse(response)

    render :json => parsed_response.dig('raw_payload', 'body'), :status => parsed_response.dig('raw_payload', 'status')
  end

  private

  def params_for_receptor
    @params_for_receptor ||= params.permit(
      :receptor_name,
      :payload => %i[method url headers data]
    )
  end
end
