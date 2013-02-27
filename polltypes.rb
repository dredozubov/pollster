class ValidationError < Exception
end

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
  module Processing
    def process_radio(question)
      processed = process_generic question
      processed['answers'] = get_enumerated_ostruct_from question['answers'], :answer
      processed
    end

    def process_multiple(question)
      # until further notice
      process_radio question
    end

    def process_text_input(question)
      process_generic question
    end

    def process_multiple_with_input(question)
      # until further notice
      process_multiple question
    end

    def process_q_method(question)
      processed = Hash.new
      processed['text'] = question['text']
      processed['type'] = question['type']
      processed['required'] = question['required'] || false
      processed['statements'] = get_enumerated_ostruct_from question['statements'], :statement
      processed['range_statements'] = get_enumerated_ostruct_from question['range_statements'], :range_statement
      processed
    end
  end

  module Validation
    def standart_error(question)
      "Answer to question #{ question['text'] } is not valid. Please report if it appears to be a bug."
    end

    def answers_per_question(question)
      question['answers'].length
    end

    def validate_radio(question, answer)
      raise ValidationError, standart_error(question) unless (0...answers_per_question(question)).include? answer.to_i
    end

    def validate_multiple(question, answers)
      range = (0...answers_per_question(question))
      raise ValidationError, standart_error(question) unless answers.all? { |a| range.include? a.to_i }
    end

    def validate_text_input(question, answer)
      raise ValidationError, standart_error(question) unless answer.is_a? String
      raise ValidationError, "Answer to question #{ question } is too long" unless answer.length < 1024
    end

    def validate_multiple_with_input(question, answers)
      validate_multiple question, answers[0...-1]
      validate_text_input question, answers[-1]
    end

    def validate_q_method(question, answers)
      range_statements = question['range_statements'].map(&:index)
      raise ValidationError, standart_error(question) unless answers.all? { |a| range_statements.include? a.to_i }
    end
  end
end