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
      :host => 'localhost',
      :port => 27017,
      :dbname => 'pollster',
      :user => 'myproductionuser',
      :password => 'mysupercoolproductionpassword'
    }

  end

  configure :production, :development do
    set :db, DatabaseBackend.new(settings.db_settings, settings.db_backend)
    enable :logging
  end

  register Sinatra::Partial
  register Barista::Integration::Sinatra
end

require './pollster'

run PollsterAppRack