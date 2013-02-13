# encoding: utf-8
require 'test/unit'
require 'rack/test'
require 'yaml'
require_relative 'pollster'
require_relative 'poll'


ENV['RACK_ENV'] = 'test'

class PollsterTest < Test::Unit::TestCase
  def setup
    @poll_file = YAML.load_file('polls/test.yaml')
    @poll = Poll.new @poll_file
  end

  def test_poll_length_and_title
    assert_equal @poll.title, 'Тестовый опрос'
    assert_equal @poll.questions.length, 7
  end

  def test_radio_parser
    assert_equal @poll.questions.first.question['type'], 'radio'
    assert_equal @poll.questions.first.question['answers'].length, 2
    answer = @poll.questions.first.question['answers'].first
    assert_equal answer.answer, "Мужской"
    assert_equal answer.index, 0
  end

  def test_text_input_parser
    assert_equal @poll.questions[2].question['type'], 'text_input'
    assert_equal @poll.questions[2].question['text'], 'Любимое слово'
  end

  def test_multiple_parser
    question = @poll.questions[3].question
    assert_equal question['type'], 'multiple'
    assert_equal question['answers'].map { |o| o.answer }.to_a, ["Green", "Yellow", "Black", "White", "Blue", "Red"]
    assert_equal question['answers'].map { |o| o.index }.to_a , (0...6).to_a
  end

  def test_multiple_with_input_parser
    question = @poll.questions[5].question
    assert_equal question['type'], 'multiple_with_input'
    assert_equal question['answers'].map { |o| o.answer }.to_a, ["Уродливый", "Красивый", "Сырой", "Крутой"]
  end

  def test_q_method
    question = @poll.questions[-1].question
    assert_equal question['type'], 'q_method'
    assert_equal question['statements'].map { |o| o.statement }.to_a, ['Я люблю печеньки', 'Я не люблю кабачки']
    assert_equal question['range_statements'].map { |o| o.range_statement }.to_a,\
                   ['Абсолютная ложь', 'Ложь', 'Не знаю', 'Правда', 'Абсолютная правда']
  end
end