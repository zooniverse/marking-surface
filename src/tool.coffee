events = [
  'mousedown', 'mouseover', 'mousmove', 'mouseout', 'mouseup'
  'touchstart', 'touchmove', 'touchend'
]

class Tool extends BaseClass
  @Mark: Mark
  @Controls: ToolControls

  markDefaults: null
  cursors: null

  mark: null
  controls: null

  group: null
  surface: null

  drags: 0

  constructor: ->
    super

    @mark ?= new @constructor.Mark

    @mark.on 'change', @onMarkChange
    @mark.on 'destroy', @onMarkDestory

    @controls = new @constructor.Controls tool: @
    @surface.container.appendChild @controls.el

    @group = @surface.svg.addShape 'g.tool'

    for eventName in events
      addEvent @group.el, eventName, @handleEvents

    @initialize arguments...

    @mark.silent = true
    @mark.set @markDefaults if @markDefaults?
    @mark.silent = false

  addShape: ->
    @group.addShape arguments...

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    @onFirstClick e

  onInitialDrag: (e) ->
    @trigger 'initial-drag', [e]
    @onFirstDrag e

  onInitialRelease: (e) ->
    @drags += 1
    @trigger 'initial-release', [e]
    @onFirstRelease e

  handleEvents: (e) =>
    return if @surface.disabled

    eventName = e.type
    name: '*' # Default for custom cursors
    target = e.target || e.srcElement # For IE

    for property, value of @
      match = value?.el is target

      if value instanceof Array
        match ||= valueItem?.el is target for valueItem in value

      if match
        name = property
        target = value

    console.log 'Handling', {name}, {target}

    @["on #{eventName}"]?.call @, e

    @["on #{eventName} #{name}"]?.call @, e

    switch eventName
      when 'mouseover'
        @surface.container.style.cursor = @cursors?[name]

      when 'mouseout'
        @surface.container.style.cursor = ''

      when 'mousedown', 'touchstart'
        e.preventDefault()

        @select()

        dragEvent = if eventName is 'mousedown' then 'mousemove' else 'touchmove'
        endEvent = if eventName is 'mousedown' then 'mouseup' else 'touchend'

        if 'on drag' of @
          @["on drag"] e

          addEvent document, dragEvent, @['on drag']

          onEnd = =>
            removeEvent document, dragEvent, @['on drag']
            removeEvent document, endEvent, onEnd

          addEvent document, endEvent, onEnd

        if "on drag #{name}" of @
          @["on drag #{name}"] e

          addEvent document, dragEvent, @["on drag #{name}"]

          onNamedEnd = =>
            removeEvent document, dragEvent, @["on drag #{name}"]
            removeEvent document, endEvent, onNamedEnd

          addEvent document, endEvent, onNamedEnd

  onMarkChange: =>
    @render arguments...
    null

  onMarkDestory: =>
    @destroy arguments...
    null

  select: ->
    @group.attr opacity: 1
    @group.toFront()
    @trigger 'select', arguments
    null

  deselect: ->
    @group.attr opacity: 0.5
    @trigger 'deselect', arguments
    null

  destroy: =>
    super

    for eventName in events
      removeEvent @group.el, eventName, @handleEvents

    # TODO: Animate this out.
    @group.remove()

    @trigger 'destroy', arguments
    null

  pointerOffset: ->
    @surface.pointerOffset arguments...

  initialize: ->
    # E.g.
    # @addShape 'circle'

  onFirstClick: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  onFirstDrag: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  isComplete: ->
    # Override this if drawing the tool requires multiple drag steps (e.g. axes).
    @drags is 1

  onFirstRelease: (e) ->
    # This is generally less useful.

  render: ->
    # E.g.
    # @circle.attr cx: @mark.position
    # @controls.moveTo @mark.position, @mark.position
