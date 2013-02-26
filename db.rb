require 'mongo'

module DBMongo
  # Mongo Connection
  include Mongo

  def get_db_connection(db_settings)
    begin
      @@db = MongoClient.new(db_settings[:host], db_settings[:port])
      @@connection = @@db.db db_settings[:dbname]
    rescue Mongo::ConnectionFailure => exc
      abort "No connection to mongodb(#{ exc }), preparing to shutdown..."
    end
  end
end


class DatabaseBackend
  attr_reader :db, :connection

  def initialize(db_settings, backend=DBMongo)
    self.class.send(:include, backend)

    get_db_connection db_settings
  end

  def save(poll_name, data)
    new_id = @@connection[poll_name].insert data
    new_id
  end
end