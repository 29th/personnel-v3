class AwardImageUploader < Shrine
  plugin :pretty_location, identifier: :code
end
