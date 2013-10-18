removeFrom = (item, array) ->
  array.splice (array.indexOf item), 1 until item not in array
  null

toggleClass = (element, className, condition) ->
  classList = element.className.match /\S+/g
  classList ?= []

  contained = className in classList

  condition ?= !contained
  condition = !!condition

  if not contained and condition is true
    classList.push className

  if contained and condition is false
    removeFrom className, classList

  element.className = classList.join ' '
  null

IE_HACK_ID = 'marking-surface-element-that-only-exists-to-please-ie'

insertStyle = (id, styleContent) ->
  document.body.insertAdjacentHTML 'afterBegin', """
    <span id="#{IE_HACK_ID}"></span>
    <style id="#{id}">#{styleContent}</style>
  """

  ieHackElement = document.getElementById IE_HACK_ID
  ieHackElement.parentNode.removeChild ieHackElement

  document.getElementById id
