class Mark extends BaseClass
  precision: 3
  ignore: ['disabled', 'ignore', 'precision']

  set: (property, value) ->
    if typeof property is 'string'
      # The return value of the method `set propertyName` will be used, if available.
      setter = @["set #{property}"]
      value = setter.call @, value if setter?
      @[property] = value
      @trigger 'change', [property, value]
    else
      properties = property
      @set property, value for property, value of properties

    return

  toJSON: ->
    # Underscore-prefixed properties will not be included in the output.
    result = {}
    for property, value of @
      continue if property in @ignore
      continue if property.charAt(0) is '_'

      if typeof value is 'number'
        parts = value.toString().split('.')
        if parts[1]?
          parts[1] = parts[1][0...@precision]
          value = parseFloat parts.join '.'
      result[property] = value

    result
