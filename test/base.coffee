MarkingSurface = require '../lib/marking-surface'
tape = require 'tape'

{BaseClass} = MarkingSurface

tape.test 'BaseClass', (t) ->
  baseInstance = new BaseClass
    someProperty: 'someValue'

  t.test 'Construction', (t) ->
    t.ok baseInstance.someProperty is 'someValue', 'Key and value passed into constructor is set on instance'
    t.end()

  t.test 'Non-DOM event handling', (t) ->
    t.plan 4

    baseInstance.on 'foo', (arg) ->
      t.ok arg is 'bar', 'Event handled by an anonymous function'

    baseInstance.handleByName = (arg) ->
      t.ok arg is 'bar', 'Event handled by a method name'

    baseInstance.on 'foo', 'handleByName'

    otherObject =
      handleElsewhereByName: (arg) ->
        t.ok arg is 'bar' and this is otherObject, 'Event handled by a named method of another object'

    baseInstance.on 'foo', [otherObject, (arg) ->
      t.ok arg is 'bar' and this is otherObject, 'Event handled by an anonymous function in the context of another object'
    ]

    baseInstance.on 'foo', [otherObject, 'handleElsewhereByName']

    baseInstance.trigger 'foo', ['bar']

  t.test 'Non-DOM event removal', (t) ->
    specificFunction = ->
      t.fail 'Specific event was not removed by function reference'

    baseInstance.on 'specific-handler-function', specificFunction
    baseInstance.off 'specific-handler-function', specificFunction
    baseInstance.trigger 'specific-handler-function'

    baseInstance.specificMethod = ->
      t.fail 'Specific event was not removed by method name'

    baseInstance.on 'specific-handler-method-reference', 'specificMethod'
    baseInstance.off 'specific-handler-method-reference', 'specificMethod'
    baseInstance.trigger 'specific-handler-method-reference'

    specificFunctionChangedContext = ->
      t.fail 'Specific event was not removed by function reference with a changed context'

    otherObject =
      otherObjectMethod: ->
        t.fail 'Specific event was not removed by method name on another object'

    baseInstance.on 'specific-handler-function-changed-context', [otherObject, specificFunctionChangedContext]
    baseInstance.off 'specific-handler-function-changed-context', [otherObject, specificFunctionChangedContext]
    baseInstance.trigger 'specific-handler-function-changed-context'

    baseInstance.on 'specific-handler-function-changed-context', [otherObject, 'otherObjectMethod']
    baseInstance.off 'specific-handler-function-changed-context', [otherObject, 'otherObjectMethod']
    baseInstance.trigger 'specific-handler-function-changed-context'

    baseInstance.on 'by-event-name', ->
      t.fail 'Event was not removed by event name'
    baseInstance.off 'by-event-name'
    baseInstance.trigger 'by-event-name'

    baseInstance.on 'all-events', ->
      t.fail 'Not all events were not removed'
    baseInstance.off()
    baseInstance.trigger 'all-events'

    setTimeout ->
      t.end()
