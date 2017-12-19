require 'sequel'

PHOTO_DB = Sequel.connect(ENV.fetch("PHOTOSTUDIO_DB", "sqlite://photostudio.db"))
class PhotostudioRecord < Sequel::Model(PHOTO_DB[:sources])
  SEQUEL_NO_ASSOCIATIONS = true
  Sequel::Model.plugin :update_or_create
end
PHOTO_DB.freeze
