require 'Psych'

polls = {}

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
    yaml  = YAML.load_file file
    p yaml
    poll = Poll.new yaml unless !yaml
  rescue Psych::SyntaxError => exc
    # sinatra logging sucks
    puts "SyntaxError(#{ exc }): #{ file } YAML poll is malformed and won't be accessible!"
  else
    # poll file is ok
    filename = Pathname.new(file).basename.to_s.split('.')[0...-1].join('.')
    polls[filename] = poll
    
    # poll
    get "/#{ filename }" do
      haml :poll, :locals => { :poll => poll }
    end

    post "/#{ filename }/validate_poll" do
      # validation
      begin
        polls[filename].validate params[:data]
      rescue ValidationError => exc
        logger.warn "Cannot validate answers(#{ exc }): #{ params[:data] }"
        halt 400
      end

      # writing to db
      begin
        logger.info params[:data]
        data = params[:data].values.map{ |x| x['data'] }.flatten.map{ |x| x != 'NaN' ? x : nil }
        settings.db.save filename, { "data" => data, "ip" => request.ip, "timestamp" => Time.new.inspect }
      rescue DatabaseWriteError => exc
        logger.error "Cannot write to database: #{ exc }"
        halt 400
      end
      # smooth execution
      status 200
    end

    get "/#{ filename }/thank_you" do
      haml :thank_you, :locals => { :message => poll.thanks_message }
    end
  end
end