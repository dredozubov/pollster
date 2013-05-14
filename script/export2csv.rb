require 'mongo'
require 'csv'

# read-only user
user = 'username'
pwd = 'password'
host = 'host.example.com'
port = 27017
dbname = 'dbname'
uri = "mongodb://#{user}:#{pwd}@#{host}:#{port}/#{dbname}"

client = Mongo::MongoClient.from_uri uri
db = client[dbname]
poll_name = ARGV[-2]
coll = db[poll_name]

data = coll.find

filepath = ARGV[-1] || './output.csv'
CSV.open(filepath, 'w') do |csv|
  data.each { |row| csv << row['data'] }
end