require 'rubygems'
require './pollster'
 
class PollsterApp < Sinatra::Application
  register Sinatra::Partial
  register Barista::Integration::Sinatra

  enable :logging
end

run Sinatra::Application