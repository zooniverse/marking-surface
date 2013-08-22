POINTER_EVENTS = [
  'mousedown', 'mouseover', 'mousmove', 'mouseout', 'mouseup'
  'touchstart', 'touchmove', 'touchend'
]

class Tool extends BaseClass
  @Mark: Mark
  @Controls: ToolControls

  cursors: null
  deselectedOpacity: 0.5
  renderFps: 30

  surface: null
  mark: null
  controls: null
  root: null
  group: null

  drags: 0
  renderTimeout: NaN

  constructor: ->
    super

    @mark ?= new @constructor.Mark

    @mark.on 'change', @onMarkChange
    @mark.on 'destroy', @onMarkDestory

    @controls = new @constructor.Controls tool: @

    # Apply filters to the root, transform the group.
    @root = @surface.addShape 'g.marking-tool-root'
    @group = @root.addShape 'g.marking-tool'
    @group.attr
      fill: 'transparent'
      stroke: 'transparent'
      strokeWidth: 0

    # Delegate pointer events to the group.
    for eventName in POINTER_EVENTS
      @group.el.addEventListener eventName, @handleEvents, false

    @initialize arguments...

  addShape: ->
    @group.addShape arguments...

  # NOTE: These "initial" events begin on the marking surface.

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

  isComplete: ->
    # Override this if drawing the tool requires multiple drag steps (e.g. axes).
    @drags is 1

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

    @["on #{eventName}"]?.call @, e

    @["on #{eventName} #{name}"]?.call @, e

    switch eventName
      when 'mouseover'
        @surface.el.style.cursor = @cursors?[name]

      when 'mouseout'
        @surface.el.style.cursor = @surface.cursor

      when 'mousedown', 'touchstart'
        e.preventDefault()

        @select()

        dragEvent = if eventName is 'mousedown' then 'mousemove' else 'touchmove'
        endEvent = if eventName is 'mousedown' then 'mouseup' else 'touchend'

        if 'on drag' of @
          @["on drag"] e

          document.addEventListener dragEvent, @['on drag'], false

          onEnd = =>
            document.removeEventListener dragEvent, @['on drag'], false
            document.removeEventListener endEvent, onEnd, false

          document.addEventListener endEvent, onEnd, false

        if "on drag #{name}" of @
          @["on drag #{name}"] e

          document.addEventListener dragEvent, @["on drag #{name}"], false

          onNamedEnd = =>
            document.removeEventListener dragEvent, @["on drag #{name}"], false
            document.removeEventListener endEvent, onNamedEnd, false

          document.addEventListener endEvent, onNamedEnd, false

  onMarkChange: =>
    return unless isNaN @renderTimeout
    @render arguments...
    @renderTimeout = setTimeout (=> @render arguments; @renderTimeout = NaN), 1000 / @renderFps

  onMarkDestory: =>
    @destroy arguments...
    null

  select: ->
    @group.attr 'opacity', 1
    @group.toFront()
    @trigger 'select', arguments
    null

  deselect: ->
    @group.attr 'opacity', @deselectedOpacity
    @trigger 'deselect', arguments
    null

  destroy: =>
    for eventName in POINTER_EVENTS
      @group.el.removeEventListener eventName, @handleEvents, false

    # TODO: Animate this out.
    @group.remove()

    super
    null

  pointerOffset: ->
    @surface.pointerOffset arguments...

  initialize: ->
    # Add shapes here.
    # E.g. @mainHandle = @addShape 'circle'

  onFirstClick: (e) ->
    # Usualy, defer to `onFirstDrag`.
    # E.g. @onFirstDrag arguments...

  onFirstDrag: (e) ->
    # Usualy, defer to a more general on-drag method.
    # E.g. @['on drag mainHandle'] arguments...

  onFirstRelease: (e) ->
    # Override this if you need to do some post-create procedure.

  render: ->
    # Reflect the state of the mark, e.g.:
    # @mainHandle.attr cx: @mark.x, cy: @mark.y
    # @controls.moveTo @mark.x, @mark.y
