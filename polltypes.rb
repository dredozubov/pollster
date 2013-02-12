require 'ostruct'


# helpers
def get_enumerated_ostruct_from(iterable, property)
  results = Array.new
  iterable.each_with_index do |value, index|
    openstruct = OpenStruct.new
    openstruct.send("#{property}=", value)
    openstruct.index = index
    results << openstruct
  end
  results
end

def process_generic(question)
  processed = Hash.new
  processed['type'] = question['type']
  processed['required'] = question['required'] || false
  processed['text'] = question['text']
  processed
end


# module containing methods corresponding to question types
module PollTypes
  def process_radio(question)
    processed = process_generic question
    processed['answers'] = get_enumerated_ostruct_from question['answers'], :answer
    processed
  end

  def process_multiple(question)
    # until further notice
    process_radio question
  end

  def process_input(question)
    process_generic question
  end

  def process_multiple_with_input(question)
    # until further notice
    process_multiple question
  end

  def process_q_method(question)
    processed = Hash.new
    processed['type'] = question['type']
    processed['required'] = question['required'] || false
    processed['statements'] = get_enumerated_ostruct_from question['statements'], :statement
    processed['range_statements'] = get_enumerated_ostruct_from question['range_statements'], :range_statement
    processed
  end
end