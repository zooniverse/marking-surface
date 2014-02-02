class Mark extends BaseClass
  ignore: ['disabled', 'ignore']

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
      result[property] = @[property]
    result
