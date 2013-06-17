TOUCH = 'Touch' of window

[START, MOVE, END] = if TOUCH
  ['touchstart', 'touchmove', 'touchend']
else
  ['mousedown', 'mousemove', 'mouseup']

BACKSPACE = 8
DELETE = 46
TAB = 9

matchesSelector = (element, selector = '*') ->
  element in document.querySelectorAll selector

events = {}

addEvent = (element, [selector]..., eventName, handler) ->
  delegatedHandler = (e) ->
    handler.apply element, e if matchesSelector e.target, selector

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
