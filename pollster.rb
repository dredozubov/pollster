not_found do
  haml :'404'
end

error do
  haml :'500'
end

get '/application.js' do
  content_type "application/javascript"
  coffee :'../public/js/application' # TODO: this is ugly, change it
end

# input polls processing
Dir.glob('polls/*.yaml').each do |file|
  begin
    poll = Poll.new YAML.load_file file
  rescue Psych::SyntaxError => exc
    # sinatra logging sucks
    puts "SyntaxError(#{ exc }): #{ file } YAML poll is malformed and won't be accessible!"
  else
    # poll file is ok
    filename = Pathname.new(file).basename.to_s.split('.')[0...-1].join('.')
    
    # poll
    get "/#{ filename }" do
      haml :poll, :locals => { :poll => poll }
    end

    post "/#{ filename }/validate_poll" do
      logger.info params[:data]
      begin
        settings.db.save filename, params[:data]
      rescue Mongo::MongoRubyError => exc
      end
      'success!'
    end

    get "/#{ filename }/thank_you" do
      haml :thank_you, :locals => { :message => poll.thanks_message }
    end
  end
end