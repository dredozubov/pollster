require 'sinatra'
require 'yaml'
require 'haml'
require 'pathname'
require 'logger'
require 'sinatra/partial'
require 'ostruct'

require_relative 'poll'

# enabling Sinatra partial-support
class Blah < Sinatra::Base
  register Sinatra::Partial
  # partial-name underscores(RoR-style)
  enable :partial_underscores
end

require_relative 'helpers'


# App

# input polls processing
Dir.glob('polls/*.yaml').each do |file|
  poll = Poll.new YAML.load_file file
  filename = Pathname.new(file).basename.to_s.split('.')[0...-1].join('.')

  get "/#{ filename }" do
    haml :poll, :locals => {:poll => poll}
  end
end

get '/' do
  haml :index
end

get '/about' do 
  haml :about
end