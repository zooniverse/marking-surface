class BaseClass
  constructor: (params = {}) ->
    @_events = {}
    @[property] = value for property, value of params

  on: (eventName, handler) ->
    @_events[eventName] ?= []
    @_events[eventName].push handler
    null

  trigger: (eventName, args = []) ->
    @_events[eventName] ?= []
    handler.apply @, args for handler in @_events[eventName]
    null

  off: (eventName, handler) ->
    if eventName?
      handlerList = @_events[eventName] || []

      if handler?
        handlerList.splice (handlerList.indexOf handler), 1

      else
        handlerList.splice 0

    else
      delete @_events[property] for property of @_events

    null

  destroy: ->
    @trigger 'destroy'
    @off()
    null
