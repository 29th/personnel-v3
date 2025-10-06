require "image_processing/mini_magick"

class ServiceCoatUploader < Shrine
  plugin :pretty_location, identifier: :friendly_id
  plugin :derivatives # , create_on_promote: true
  plugin :determine_mime_type
  plugin :store_dimensions, analyzer: :mini_magick

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    width = magick.width
    height = 312
    x_offset = 0
    y_offset = record.rank&.officer? ? 130 : 199

    {
      sig: magick.crop("#{width}x#{height}+#{x_offset}+#{y_offset}") # TODO: repage
    }
  end
end
