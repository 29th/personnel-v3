class RankImageUploader < Shrine
  plugin :pretty_location, identifier: :slug
end
