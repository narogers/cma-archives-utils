require 'sequel'

class AthenaRecord < Sequel::Model(:accessions)
  SEQUEL_NO_ASSOCIATIONS = true
  Sequel::Model.plugin :update_or_create
end
