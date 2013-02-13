require 'sinatra'
require 'barista'
require 'yaml'
require 'haml'
require 'pathname'
require 'logger'
require 'sinatra/partial'
require 'ostruct'
require './helpers'
require './poll'
# require './db'

# enabling Sinatra partial-support
class PollsterApp < Sinatra::Application
  register Sinatra::Partial
  register Barista::Integration::Sinatra
end


not_found do
  haml :'404'
end

error do
  haml :'500'
end

# input polls processing
Dir.glob('polls/*.yaml').each do |file|
  poll = Poll.new YAML.load_file file
  filename = Pathname.new(file).basename.to_s.split('.')[0...-1].join('.')

  get "/#{ filename }" do
    haml :poll, :locals => {:poll => poll}
  end
end
