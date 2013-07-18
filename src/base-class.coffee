jQuery = window.jQuery
# TODO: Remove jQuery dependency.

class BaseClass
  jQueryEventProxy: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @jQueryEventProxy = new jQuery {}

  destroy: ->
    @trigger 'destroy'
    @off()

  for method in ['on', 'one', 'trigger', 'off'] then do (method) =>
    @::[method] = ->
      @jQueryEventProxy[method] arguments...
