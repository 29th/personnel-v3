class UnitLogoImageUploader < Shrine
  plugin :pretty_location, identifier: :slug
  plugin :validation_helpers
  plugin :store_dimensions

  Attacher.validate do
    validate_size 1..1*1024*1024 # Between 1B and 1 MB
    validate_mime_type %w[image/jpeg image/png image/webp]
    validate_extension %w[jpg jpeg png webp]
    validate_max_dimensions [500, 500]
  end
end
