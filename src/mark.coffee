class Mark extends BaseClass
  set: (property, value, {fromMany} = {}) ->
    if typeof property is 'string'
      # The return value of a method named "set propertyName" will be used, if available.
      setter = @["set #{property}"]
      setValue = if setter? then setter.call @, value else value
      @[property] = setValue

      # Specific changes will be triggered.
      @trigger "change-property", [setValue]

    else
      properties = property
      @set property, value, fromMany: true for property, value of properties

    # One generic change will be triggered, but its arguments can't really be trusted.
    @trigger 'change', [property, value] unless fromMany

    null

  toJSON: ->
    result = {}

    for property, value of @
      # Underscore-prefixed properties will not be included in the output.
      continue if (property.charAt 0) is '_'
      continue if typeof value is 'function'
      result[property] = @[property]

    result
