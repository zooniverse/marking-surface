unless 'classList' of document.body
  throw new Error 'MarkingSurface requires `classList` or a polyfill'

BACKSPACE = 8
DELETE = 46
TAB = 9

elementAndParents = (element) ->
  elements = []
  currentElement = element
  while currentElement?
    elements.push currentElement
    currentElement = currentElement.parentNode

  elements

addEvent = (element, eventName, handler) ->
  element.addEventListener eventName, handler, false
  null

removeEvent = (element, eventName, handler) ->
  element.removeEventListener eventName, handler, false
  null
