require 'mongo'

# Mongo Connection
include Mongo
mongo_host = "localhost"
mongo_port = 27017
mongo_db = "pollster"
db = MongoClient.new(mongo_host, mongo_port).db(mongo_db)