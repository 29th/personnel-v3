require 'image_processing/mini_magick'

class RankImageUploader < Shrine
  plugin :pretty_location, identifier: :slug
  plugin :derivatives

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)

    {
      icon: magick.resize_to_limit!(16, 16)
    }
  end
end
