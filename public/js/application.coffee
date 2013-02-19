savePollURL = window.location.href + '/validate_poll'
thankYouURL = window.location.href + '/thank_you'

toCamelCase = (string) ->
  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)
  uncapitalize = (string) -> 
    string.charAt(0).toLowerCase() + string.slice(1)
  words = string.split('_').map (word) =>
    lowerCased = word.toLowerCase()
    capitalize(lowerCased)
  joined = words.join('')
  uncapitalize joined

savePollAjax = (validatedData) ->
  for d in validatedData
    console.log d
  request = $.post savePollURL, 
    data: validatedData
    datatype: 'json'
  request.success (data) ->
    window.location.href = thankYouURL
  request.error (jqXHR, textStatus, errorThrown) -> alert("AJAX Error: #{[textStatus, errorThrown]}")

setQuestionError = (question_id, errorText) ->
  $("##{question_id} span").addClass("error").text(errorText)

removeQuestionError = (question_id) ->
  $("##{question_id} span").empty()

class Validator
  @validate: (questionId) ->
    self = this
    question = $("##{questionId}")
    questionType = question.attr('type')
    method = toCamelCase("validate_#{questionType}")
    if @[method]
      @[method](questionId)
    else
      console.log "missing validator for #{}"
      setQuestionError question.attr('id'), 'missing validator'
      false

  @validateRadio: (questionId) ->
    if $("input[name='#{questionId}'][type='radio']:checked").length
      removeQuestionError questionId
      true
    else
      setQuestionError questionId, 'required'
      false

  @validateMultiple: (questionId) ->
    if $("input[name='#{questionId}'][type='checkbox']:checked").length
      removeQuestionError questionId
      true
    else
      setQuestionError questionId, 'required'
      false

  @validateMultipleWithInput: (questionId) ->
    @.validateMultiple questionId

  @validateTextInput: (questionId) ->
    if do $("input[name='#{questionId}'][type='text']").val
      removeQuestionError questionId
      true
    else
      setQuestionError questionId, 'required'
      false

class Collector
  @collectRadio: (questionId) ->
    $("input[name='#{questionId}'][type='radio']:checked").attr('id')

  @collectMultiple: (questionId) ->
    $.map($("input[name='#{questionId}'][type='checkbox']:checked"), (elem) => elem.getAttribute('id'))

  @collectMultipleWithInput: (questionId) ->
    {'checked': Collector.collectMultiple(questionId), 'text': Collector.collectTextInput(questionId)}

  @collectTextInput: (questionId) ->
    do $("input[name='#{questionId}'][type='text']").val

  @collect: (questions) -> 
    result = []
    for question in questions
      data = {}
      questionId = question.getAttribute('id')
      splitted = questionId.split('_')
      id = splitted[splitted.length - 1]
      method = toCamelCase("collect_#{question.getAttribute('type')}")
      if Collector[method]
        data['data'] = Collector[method] questionId
      else
        data['data'] = null
      data['id'] = id
      result.push data
    result

save = ->
  isOk = true
  for question, i in $(".question[required='true']")
    unless Validator.validate(question.getAttribute("id"))
      console.log 'validation failed'
      isOk = false
  if isOk
    console.log 'ok'
    savePollAjax(Collector.collect($(".question")))

init = ->
  $("#save_poll_btn").bind "click", save

$ ->
  init()