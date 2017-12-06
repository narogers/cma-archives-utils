require 'sequel'

DB = Sequel.connect('sqlite://photostudio.db')
class PhotostudioRecord < Sequel::Model(DB[:sources])
  SEQUEL_NO_ASSOCIATIONS = true
  Sequel::Model.plugin :update_or_create
end
