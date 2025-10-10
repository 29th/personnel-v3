require "image_processing/mini_magick"

class ServiceCoatUploader < Shrine
  plugin :pretty_location, identifier: :friendly_id
  plugin :derivatives
  plugin :determine_mime_type
  plugin :store_dimensions, analyzer: :mini_magick

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    crop_width = 800
    crop_height = 312
    crop_x_offset = 0
    crop_y_offset = record.rank&.officer? ? 130 : 199

    resized_width = 332
    resized_height = 128

    sig_derivative = magick
      .crop("#{crop_width}x#{crop_height}+#{crop_x_offset}+#{crop_y_offset}")
      .resize("#{resized_width}x#{resized_height}!")

    {
      sig: sig_derivative.call
    }
  end
end
