Faraday::ClientError.class_eval do
  def to_honeybadger_context
    {
      response_status: response_status,
      response_headers: response_headers,
      response_body: response_body,
      request: request
    }
  end

  def request
    @response[:request] if @response
  end
end
