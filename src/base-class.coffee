DEV_PORT = +location.port > 1023
LOG_EVENTS = !!~location.search.indexOf 'log=1'

if DEV_PORT
  window.MARKING_SURFACE_OBJECTS = []

arraysMatch = (a1, a2) ->
  if a1 is a2
    true
  else if a1.length is a2.length
    for i in [0...a1.length]
      unless a1[i] is a2[i]
        return false
    true
  else
    false

class BaseClass
  constructor: (params = {}) ->
    if DEV_PORT
      window.MARKING_SURFACE_OBJECTS.push this

    @_events = {}

    for property, value of params
      @[property] = value

  on: (eventName, handler) ->
    @_events[eventName] ?= []
    @_events[eventName].push handler

  trigger: (eventName, args = []) ->
    if LOG_EVENTS
      console?.group @el ? @constructor.name, eventName, args

    if eventName of @_events
      for handler in @_events[eventName]
        @applyHandler handler, args

    if LOG_EVENTS
      console?.groupEnd()

  applyHandler: (handler, givenArgs = []) ->
    context = this

    if handler instanceof Array
      [context, handler, savedArgs...] = handler

    savedArgs ?= []

    if typeof handler is 'string'
      handler = context[handler]

    handler.call context, savedArgs..., givenArgs...

  off: (eventName, handler) ->
    if eventName?
      if eventName of @_events
        handlerList = @_events[eventName]
        if handler?
          handlerIndex = if handler instanceof Array
            (i for h, i in handlerList by -1 when arraysMatch handler, h)[0] ? -1
          else
            handlerList.indexOf handler

          if handlerIndex >= 0
            handlerList.splice handlerIndex, 1
        else
          handlerList.splice 0
    else
      for property of @_events
        @_events[property].splice 0

  destroy: ->
    # Note, call `super` at the _end_ of any methods that extend this.
    @trigger 'marking-surface:base:destroy'
    @off()

    if DEV_PORT
      index = window.MARKING_SURFACE_OBJECTS.indexOf this
      window.MARKING_SURFACE_OBJECTS.splice index, 1
