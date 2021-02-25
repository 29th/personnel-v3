require 'shrine'

if Rails.env.test? || ENV['PRECOMPILE']
  require 'shrine/storage/memory'

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }

  Shrine.logger.level = Logger::WARN
else
  require 'shrine/storage/s3'

  s3_opts = {
    bucket: ENV['STORAGE_BUCKET'],
    region: ENV['STORAGE_REGION'],
    access_key_id: ENV['STORAGE_ACCESS_KEY_ID'],
    secret_access_key: ENV['STORAGE_SECRET_ACCESS_KEY'],
    endpoint: ENV['STORAGE_ENDPOINT'],
    public: true
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_opts),
    store: Shrine::Storage::S3.new(prefix: 'personnel', **s3_opts)
  }

  Shrine.plugin :url_options, store: { host: ENV['STORAGE_PUBLIC_HOST'] }
end

Shrine.plugin :instrumentation, notifications: ActiveSupport::Notifications
Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data

Shrine.logger = Rails.logger
