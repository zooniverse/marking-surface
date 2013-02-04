class Mark extends BaseClass
  set: (property, value, {fromMany} = {}) ->
    if typeof property is 'string'
      setter = @["set #{property}"]
      @[property] = if setter then setter.call @, value else value

    else
      map = property
      @set property, value, fromMany: true for property, value of map

    @trigger 'change', property, value unless fromMany

  toJSON: ->
    result = {}

    for property, value of @
      continue if property is 'jQueryEventProxy'
      continue if typeof value is 'function'
      result[property] = value

    result
