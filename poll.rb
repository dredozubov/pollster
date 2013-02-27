require './polltypes'


class Poll
  include PollTypes::Processing
  include PollTypes::Validation
  attr_reader :title, :questions, :type, :description, :thanks_message
  
  def initialize(poll_hash)
    @question_counter = 0
    @title = poll_hash['title']
    @description = poll_hash['description']
    @thanks_message = poll_hash['thanks_message']
    @questions = process_questions poll_hash['questions']
  end

  def process_questions(questions)
    result = []
    questions.each do |q|
      method = "process_#{ q['type'] }"
      if respond_to? method
        ostruct = OpenStruct.new
        ostruct.question = send(method, q)
        ostruct.index = @question_counter
        @question_counter += 1
        result << ostruct
      else
        puts "missing processing method: #{ method }"
        next
      end
    end
    result
  end

  def length
    @question_counter
  end

  def validate(data)
    if @question_counter != data.length
      raise ValidationError, "question number is not valid: #{ data.length } out of #{ @question_counter }"
    end
    answer_data_array = data.map{ |x| x[1]['data'] }
    @questions.map(&:question).zip(answer_data_array).select{ |x| x[0]['required'] }.each do |question, answers|
      method = "validate_#{ question['type'] }"
      if respond_to? method
        send(method, question, answers)
      else
        puts "missing validation method: #{ method }"        
      end
    end
  end
end