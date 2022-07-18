require "shrine"

if Rails.env.test? || ENV["PRECOMPILE"]
  require "shrine/storage/memory"

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }

  Shrine.logger.level = Logger::WARN
elsif Rails.env.production?
  require "shrine/storage/s3"

  config = Rails.configuration.endpoints[:storage]
  s3_opts = {
    bucket: config[:bucket],
    region: config[:region],
    access_key_id: config[:access_key_id],
    secret_access_key: config[:secret_access_key],
    endpoint: config[:endpoint],
    public: true
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_opts),
    store: Shrine::Storage::S3.new(prefix: "personnel", **s3_opts)
  }

  Shrine.plugin :url_options, store: {host: config[:public_host]}
else # development
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads")
  }
end

Shrine.plugin :instrumentation, notifications: ActiveSupport::Notifications
Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :remove_attachment

Shrine.logger = Rails.logger
