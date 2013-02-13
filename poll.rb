require_relative 'polltypes'

class Poll
  include PollTypes
  attr_reader :title, :questions, :type
  
  def initialize(poll_hash)
    @question_counter = 0
    @title = poll_hash['title']
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
        next
      end
    end
    result
  end

  def length
    @question_counter
  end
end