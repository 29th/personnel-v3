class GenerateServiceCoatJob < ApplicationJob
  queue_as :default

  class ServiceCoatGenerationError < StandardError; end

  def perform(user)
    response = connection.post("/") do |request|
      authorize(request)
      request.headers["Accept"] = "image/png"
      request.body = request_payload_for(user)
    end

    unless response.success?
      raise ServiceCoatGenerationError, "service coat generator responded with #{response.status}"
    end

    attach_response_to_user(user, response)
  end

  private

  def connection
    @connection ||= Faraday.new(Settings.service_coat_generator.base_url.internal) do |conn|
      conn.request :json
      conn.adapter Faraday.default_adapter
    end
  end

  def authorize(request)
    api_key = Settings.service_coat_generator.api_key
    request.headers["Authorization"] = "Bearer #{api_key}" if api_key.present?
  end

  def request_payload_for(user)
    unit = current_unit_for(user)

    {
      last_name: user.last_name,
      rank_abbr: user.rank&.abbr,
      unit_key: unit_key_for(unit),
      awards_abbr: user.awards.pluck(:code),
      balance: FinanceRecord.user_donated(user)
    }.compact
  end

  def current_unit_for(user)
    user.active_assignments.includes(:unit).order(start_date: :desc).first&.unit ||
      user.assignments.includes(:unit).order(start_date: :desc).first&.unit
  end

  def unit_key_for(unit)
    unit&.v2_slug || unit&.abbr
  end

  def attach_response_to_user(user, response)
    prefix = user.steam_id || user.id
    tempfile = Tempfile.new([prefix.to_s, ".png"])
    tempfile.binmode
    tempfile.write(response.body)
    tempfile.rewind

    prepare_for_uploader(tempfile, response)

    user.service_coat = tempfile
    user.save!(validate: false)
  ensure
    tempfile&.close!
  end

  def prepare_for_uploader(tempfile, response)
    filename = "service-coat.png"
    content_type = response.headers["content-type"] || "image/png"

    tempfile.define_singleton_method(:original_filename) { filename }
    tempfile.define_singleton_method(:content_type) { content_type }
  end
end
