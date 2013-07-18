class BaseClass
  events: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @events = {}

  on: (eventName, handler) ->
    @events[eventName] ?= []
    @events[eventName].push handler
    null

  trigger: (eventName, args) ->
    handler.apply @, args || [] for handler in @events[eventName] || []
    null

  off: (eventName, handler) ->
    if eventName? and handler?
      for h, i in @events[eventName] when h is handler
        (@events[eventName] || []).splice i, 1
        return

    else if eventName?
      (@events[eventName] || []).splice 0
    else
      delete @events[property] for property of @events

    null

  destroy: ->
    @trigger 'destroy'
    @off()
    null
