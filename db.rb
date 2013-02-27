require 'mongo'


class DatabaseWriteError < Exception
end

module DBMongo
  # Mongo Connection
  include Mongo

  def get_db_connection(db_settings)
    begin
      @@client = MongoClient.new(db_settings[:host], db_settings[:port])  
      @@db = @@client.db db_settings[:dbname]

      if db_settings[:user]
        unless @@db.authenticate(db_settings[:user], db_settings[:password])
          abort "Cannot authenticate to the database, preparing to shutdown..." 
        end
      end

    rescue Mongo::ConnectionFailure => exc
      abort "No connection to mongodb(#{ exc }), preparing to shutdown..."
    end
  end

  def save(poll_name, data)
    begin
      new_id = @@db[poll_name].insert data
    rescue Mongo::MongoRubyError => exc
      raise DatabaseWriteError, exc
    end
    new_id
  end
end


class DatabaseBackend
  attr_reader :db, :connection

  def initialize(db_settings, backend=DBMongo)
    self.class.send(:include, backend)

    get_db_connection db_settings
  end
end