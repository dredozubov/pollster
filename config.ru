require 'rubygems'
require './pollster'
 
class PollsterApp < Sinatra::Application
  register Sinatra::Partial

  # Barista (for CoffeeScript Support)
  Barista.configure do |b|
    b.app_root = settings.root
    b.root = File.join(root, 'public/js/')
  end
  register Barista::Integration::Sinatra

  enable :logging
end

run Sinatra::Application