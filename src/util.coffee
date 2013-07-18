unless 'classList' of document.body
  throw new Error 'MarkingSurface requires `classList` or a polyfill'

BACKSPACE = 8
DELETE = 46
TAB = 9

events = {}

elementAndParents = (element) ->
  elements = []
  currentElement = element
  while currentElement?
    elements.push currentElement
    currentElement = currentElement.parentNode

  elements

matchesSelector = (element, selector, root = document) ->
  element in root.querySelectorAll selector

addEvent = (element, [selector]..., eventName, handler) ->
  delegatedHandler = (e) ->
    if selector?
      matched = false
      for element in elementAndParents e.target
        if matchesSelector element, selector
          matched = true

    if (not selector?) or matched
      handler.call element, e

  events[eventName] ?= []
  events[eventName].push {element, selector, handler, delegatedHandler}

  element.addEventListener eventName, delegatedHandler, false
  null

removeEvent = (element, [selector]..., eventName, handler) ->
  for set, i in events[eventName]
    if element is set.element and selector is set.selector and handler is set.handler
      element.removeEventListener eventName, set.delegatedHandler, false
      events[eventName].splice i, 1
      return
  null
