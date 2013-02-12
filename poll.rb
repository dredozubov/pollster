require_relative 'polltypes'

class Poll
  include PollTypes
  attr_reader :title, :questions, :type
  
  def initialize(poll_hash)
    @title = poll_hash['title']
    @questions = process_questions poll_hash['questions']
  end

  def process_questions(questions)
    result = []
    questions.each do |q|
      method = "process_#{ q['type'] }"
      result << send(method, q) if respond_to? method
    end
    result
  end
end