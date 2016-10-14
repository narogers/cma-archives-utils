require 'sequel'

class PhotostudioRecord < Sequel::Model(:sources)
  SEQUEL_NO_ASSOCIATIONS = true
  Sequel::Model.plugin :update_or_create
end
