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
  console.log "savePollURL: #{savePollURL}"
  request = $.post savePollURL, 
    data: validatedData
    datatype: 'json'
  request.success (data) ->
    window.location.href = thankYouURL
  request.error (jqXHR, textStatus, errorThrown) -> alert("AJAX Error: #{[textStatus, errorThrown]}")

setQuestionError = (question_id, errorText) ->
  $("##{question_id} span.validation").addClass("error").text(errorText)

removeQuestionError = (question_id) ->
  $("##{question_id} span.validation").empty()

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

  @validateQMethod: (questionId) ->
    numberSet = $("##{ questionId } .statements .statement[set='true']").length
    numberTotal = $("##{ questionId } .statements .statement").length
    if numberTotal == numberSet
      removeQuestionError questionId
      true
    else
      setQuestionError questionId, 'not complete'
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

  @collectQMethod: (questionId) ->
    result = {}
    $("##{ questionId } .statements .statement").each (index, statement) =>
      result[statement.getAttribute('id')] = statement.getAttribute('range_statement')
    result

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
      isOk = false
  if isOk
    savePollAjax(Collector.collect($(".question")))

setStatement = (questionId) ->
  visible = $("##{ questionId } .statements .statement:visible:first")
  if visible.length
    rangeStatementId = $("input[name='#{questionId}'][type='radio']:checked").attr('id')
    visible.attr('range_statement', rangeStatementId)
    visible.attr('set', 'true')
    do visible.hide

unsetStatement = (questionId, statementId) ->
  statement = $("##{ questionId } .statements .statement[id='#{ statementId }']")
  statement.removeAttr('set')
  statement.removeAttr('range_statement')
  $("##{ questionId } .progress span.current").text $("##{ questionId } .statements .statement[set='true']").length
  $("##{ questionId } #select_statement").show()

init_q_method_questions = ->
  $(".question[type='q_method']").each (index, question) =>
    questionId = question.getAttribute('id')
    # show initial state
    $("##{ questionId } .statements .statement:first").show()
    $("##{ questionId } .progress").show()
    $("##{ questionId } .range_statements").show()
  $(".question[type='q_method'] #select_statement").each (index, question) => 
    questionId = question.parentNode.getAttribute('id')
    $("##{ questionId } #select_statement").click (btn) =>
      # make sure at least one range statement is checked
      if $("input[name='#{ questionId }'][type='radio']:checked").length
        total = $("##{ questionId } .progress span.length")
        current = $("##{ questionId } .progress span.current")
        setStatement questionId
        # show next statement
        do $("##{ questionId } .statements .statement:not([set]):first").show
        # update progress counter
        current.text $("##{ questionId } .statements .statement[set='true']").length
        # if all statements are checked, then hide "next" button
        if $.trim(total.text()) == $.trim(current.text())
          $("##{ questionId } #select_statement").hide()

init = ->
  do init_q_method_questions
  $("#save_poll_btn").bind "click", save

$ ->
  init()