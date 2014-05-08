class Mark extends BaseClass
  precision: 3
  ignore: ['disabled', 'ignore', 'precision']

  set: (property, value, _partial = false) ->
    if typeof property is 'string'
      # The return value of the method `set propertyName` will be used, if available.
      setter = @["set #{property}"]
      value = setter.call @, value if setter?
      @[property] = value
    else
      properties = property
      for property, value of properties
        @set property, value, true

    unless _partial
      @trigger 'marking-surface:mark:change'

    return

  toJSON: ->
    result = {}

    for property, value of @
      # Underscore-prefixed properties will not be included in the output.
      continue if property.charAt(0) is '_'
      continue if property in @ignore

      if typeof value is 'number'
        parts = value.toString().split('.')
        if parts[1]?
          parts[1] = parts[1][0...@precision]
          value = parseFloat parts.join '.'
      result[property] = value

    result
