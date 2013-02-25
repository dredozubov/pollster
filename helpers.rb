def generic_partial(question, index)
  partial(:"_#{question['type']}", :locals => {
  :text => question['text'],
  :answers => question['answers'],
  :required => question['required'],
  :index => index
  })
end

module Haml
  module Helpers
    def render_question(question, index)
      case question['type']
      when 'radio'
        generic_partial question, index
      when 'multiple'
        generic_partial question, index
      when 'text_input'
        partial(:_text_input, :locals => {
          :text => question['text'],
          :required => question['required'],
          :index => index
          })
      when 'multiple_with_input'
        generic_partial question, index
      when 'q_method'
        partial(:_q_method, :locals => {
          :type => question['type'],
          :required => question['required'],
          :statements => question['statements'],
          :range_statements => question['range_statements'],
          :index => index
          })
      end
    end
  end
end