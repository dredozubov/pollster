require 'sinatra'
require 'barista'
require 'yaml'
require 'haml'
require 'pathname'
require 'sinatra/partial'
require 'ostruct'
require './helpers'
require './poll'
# require './db'


not_found do
  haml :'404'
end

error do
  haml :'500'
end

get '/application.js' do
  # coffee :application\
  content_type "application/javascript"
  coffee :'../public/js/application' # TODO: this is ugly
end

# input polls processing
Dir.glob('polls/*.yaml').each do |file|
  poll = Poll.new YAML.load_file file
  filename = Pathname.new(file).basename.to_s.split('.')[0...-1].join('.')
  
  # poll
  get "/#{ filename }" do
    haml :poll, :locals => { :poll => poll }
  end

  post "/#{ filename }/validate_poll" do
    logger.info params[:data]
  end

  get "/#{ filename }/thank_you" do
    haml :thank_you, :locals => { :message => poll.thanks_message }
  end
end