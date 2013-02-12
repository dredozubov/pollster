require 'sinatra'
require 'yaml'
require 'haml'
require 'logger'
require_relative 'poll'

log = Logger.new(STDOUT)
log.level = Logger::WARN

# input polls processing
Dir.glob('polls/*.yaml').each do |file|
  poll = Poll.new YAML.load_file file

  get "/#{poll.title}" do
    logger.debug poll.title
    haml :poll
  end
end

get '/' do
  haml :index
end

get '/about' do 
  haml :about
end