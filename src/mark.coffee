class Mark extends BaseClass
  set: (property, value) ->
    if typeof property is 'string'
      setter = @["set #{property}"]
      @[property] = if setter? then setter.call @, value else value
      @trigger 'change', [property, value]

    else
      map = property
      @set property, value for property, value of map

    null

  get: (properties...) ->
    values = for property in properties
      getter = @["get #{property}"]
      if getter? then getter.call @ else @[property]

    if properties.length is 1
      values[0]
    else
      values

  toJSON: ->
    result = {}

    for property, value of @
      continue if property is 'jQueryEventProxy'
      continue if typeof value is 'function'
      continue if (property.charAt 0) is '_'
      getter = @["get #{property}"]
      result[property] = @get property

    result
