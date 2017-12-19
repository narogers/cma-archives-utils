require 'sequel'

ATHENA_DB = Sequel.connect(ENV.fetch("ATHENA_DB", "sqlite://accession_numbers.db"))
class AthenaRecord < Sequel::Model(ATHENA_DB[:accessions])
  SEQUEL_NO_ASSOCIATIONS = true
  Sequel::Model.plugin :update_or_create
end
ATHENA_DB.freeze
