class BaseClass
  _events: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @_events = {}

  on: (eventName, handler) ->
    @_events[eventName] ?= []
    @_events[eventName].push handler
    null

  trigger: (eventName, args) ->
    handler.apply @, args || [] for handler in @_events[eventName] || []
    null

  off: (eventName, handler) ->
    if eventName?
      handlerList = @_events[eventName] || []

      if handler?
        for fn, i in handlerList by -1 when fn is handler
          handlerList.splice i, 1

      else
        handlerList.splice 0

    else
      delete @_events[property] for property of @_events

    null

  destroy: ->
    @trigger 'destroy'
    @off()
    null
