require 'rubygems'
require 'sinatra'
require 'barista'
require 'yaml'
require 'haml'
require 'pathname'
require 'sinatra/partial'
require 'ostruct'

require './helpers'
require './poll'
require './db'


class PollsterAppRack < Sinatra::Application
  configure :development do
    set :db_backend, DBMongo
    set :db_settings, { 
      :host => 'localhost',
      :port => 27017,
      :dbname => 'pollster',
    }
  end

  configure :production do
    set :db_backend, DBMongo
    set :db_settings, {
      :host => 'ds031957.mongolab.com',
      :port => 31957,
      :dbname => 'heroku_app11809717',
      :user => 'pollster',
      :password => 'myawesomepassword'
    }

  end

  configure :production, :development do
    set :db, DatabaseBackend.new(settings.db_settings, settings.db_backend)
    enable :logging
  end

  register Sinatra::Partial
  register Barista::Integration::Sinatra
end

# this makes tilt to treat templates as properly encoded (respect Encoding.default_external)
# taken from http://stackoverflow.com/questions/10828668/padrino-sass-coffee-encodingundefinedconversionerror-from-ascii-8bit-to
module Tilt
  class CoffeeScriptTemplate
    def prepare
      @data.force_encoding Encoding.default_external
      if !options.key?(:bare) and !options.key?(:no_wrap)
        options[:bare] = self.class.default_bare
      end
    end
  end
end


require './pollster'

run PollsterAppRack