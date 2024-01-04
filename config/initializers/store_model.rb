# Omit attributes that aren't explicitly defined in StoreModel
# models from being included when serialized
# https://github.com/DmitryTsepelev/store_model/blob/master/docs/unknown_attributes.md
StoreModel.config.serialize_unknown_attributes = false
