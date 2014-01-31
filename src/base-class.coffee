class BaseClass
  constructor: (params = {}) ->
    @_events = {}
    for property, value of params
      @[property] = value

  on: (eventName, handler) ->
    @_events[eventName] ?= []
    @_events[eventName].push handler

  trigger: (eventName, args = []) ->
    if eventName of @_events
      for handler in @_events[eventName]
        handler.apply @, args

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
    @trigger 'destroy'
    @off()
