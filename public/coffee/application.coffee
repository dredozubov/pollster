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
    parseInt $("input[name='#{questionId}'][type='radio']:checked").attr('id')

  @collectMultiple: (questionId) ->
    result = []
    $("input[name='#{questionId}'][type='checkbox']").each (index, elem) =>
      if elem.checked
        val = 1
      else
        val = 0
      result.push val
    result

  @collectMultipleWithInput: (questionId) ->
    multiple = Collector.collectMultiple(questionId)
    text = Collector.collectTextInput(questionId)
    multiple.push text
    multiple

  @collectTextInput: (questionId) ->
    do $("input[name='#{questionId}'][type='text']").val || NaN

  @collectQMethod: (questionId) ->
    $.makeArray($("##{ questionId } .statements .statement").map (index, statement) =>
      statement.getAttribute('range_statement') || NaN)

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

moveStatement = (from, to, draggableOptions) ->
  splitted = to.attr('id').split('-')
  accordionId = splitted[2]
  tabId = splitted[4]

  toSelector = ".ui-accordion-content#ui-accordion-#{ accordionId }-panel-#{ tabId }"
  unless to.is(toSelector)
    to = to.siblings(toSelector)

  # clone element
  newElement = do from.clone

  # make it draggable
  newElement.addClass 'draggable'
  newElement.draggable draggableOptions

  # append it to accordion tab
  newElement = to.append(newElement)

  # make sure statement moved from general list, not from accordion
  parent = $(from.parent().get(0))
  questionId = from.parents('.question').attr('id')
  
  # remove source element
  do from.remove

  if parent.hasClass 'statements'
    # if moved from general list of statement, show next stement, update progress
    showNextStatement questionId
    updateProgressBar questionId

saveAccordionState = (accordion) ->
  accordion.accordion("option")

showNextStatement = (questionId) ->
  do $("##{ questionId } .statements .statement:first").show

updateProgressBar = (questionId) ->
  total = parseInt($("##{ questionId } .statements").attr('total'))
  current = parseInt($("##{ questionId } .statements p.statement").length)
  $("##{ questionId } .progress span.current").text(total - current)
  console.log "total - current: #{current}"

init_q_method_questions = ->
  $(".question[type='q_method']").each (index, question) =>
    questionId = question.getAttribute('id')
    # show initial state
    showNextStatement questionId

save = ->
  isOk = true
  for question, i in $(".question[required='true']")
    unless Validator.validate(question.getAttribute("id"))
      isOk = false
  if isOk
    savePollAjax(Collector.collect($(".question")))


init = ->
  do init_q_method_questions
  $("#save_poll_btn").bind "click", save
  draggableOptions = { snap: '.droppable-range-statement', snapTolerance: 10, revert: 'invalid', containment: 'parent', revert: true, cursor: 'move', helper: 'clone', appendTo: 'body', cursorAt: { top: 5, left: 5 } }
  $(".draggable").draggable draggableOptions
  accordion_params = { collapsible: true, active: false, heightStyle: 'content' }
  $(".accordion").accordion accordion_params
  $(".droppable").droppable {
    drop: (event, ui) ->
      moveStatement($(ui.draggable), $(this), draggableOptions)
      accordion = do $(this).parent
      accordionState = saveAccordionState accordion
      accordion.accordion('destroy').accordion accordionState
  }

$ ->
  init()