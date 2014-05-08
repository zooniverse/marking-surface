LOG_EVENTS = !!~location.search.indexOf 'log=1'

class BaseClass
  constructor: (params = {}) ->
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
          handlerIndex = handlerList.indexOf handler
          handlerList.splice handlerIndex, 1
        else
          handlerList.splice 0
    else
      for property of @_events
        delete @_events[property]

  destroy: ->
    # Note, call `super` at the _end_ of any methods that extend this.
    @trigger 'marking-surface:base:destroy'
    @off()
