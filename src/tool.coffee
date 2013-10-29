POINTER_EVENTS = [
  'mousedown', 'mouseover', 'mousemove', 'mouseout', 'mouseup'
  'touchstart', 'touchmove', 'touchend'
]

[PREFIXED_GRAB, PREFIXED_GRABBING] = if 'webkitMatchesSelector' of document.body
  ['-webkit-grab', '-webkit-grabbing']
else if 'mozMatchesSelector' of document.body
  ['-moz-grab', '-moz-grabbing']
else
  ['move', 'move']

class Tool extends BaseClass
  @Mark: Mark
  @Controls: ToolControls

  cursors: null
  renderFps: 30

  drags: 0
  renderTimeout: NaN

  constructor: ->
    super

    @mark = new @constructor.Mark

    @mark.on 'change', =>
      return unless isNaN @renderTimeout
      @render arguments...
      @renderTimeout = setTimeout (=> @render arguments; @renderTimeout = NaN), 1000 / @renderFps

    @mark.on 'destroy', =>
      @destroy arguments...

    @controls = new @constructor.Controls tool: @

    # Apply filters to the root, transform the group.
    @root = @surface.addShape 'g.marking-tool-root'
    @group = @root.addShape 'g.marking-tool-group'
    @group.attr
      fill: 'transparent'
      stroke: 'transparent'
      strokeWidth: 0

    # Delegate pointer events to the group.
    for eventName in POINTER_EVENTS
      @root.el.addEventListener eventName, @handleEvents, false

    @initialize arguments...

  addShape: ->
    @group.addShape arguments...

  # NOTE: These "initial" events originate on the marking surface.

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
    target = e.target || e.srcElement # srcElement is for IE.

    matchingNames = []
    for own property, value of @
      if value?.el is target
        matchingNames.push property

      else
        if value instanceof Array
          for valueItem in value
            if valueItem?.el is target
              matchingNames.push property
              break

    @["on #{eventName}"]?.call @, e
    @["on #{eventName} #{name}"]?.call @, e for name in matchingNames

    switch eventName
      when 'mouseover'
        # Firefox wants to trigger then when the mouse moves, which replaces the grabbing cursor.
        unless @surface.el.style.cursor is PREFIXED_GRABBING
          if @cursors? then for name in matchingNames
            if @cursors[name] is '*grab'
              @surface.el.style.cursor = PREFIXED_GRAB
            else
              @surface.el.style.cursor = @cursors[name]

      when 'mousemove', 'touchmove'
        @['on *move']?.call @, e
        @["on *move #{name}"]?.call @, e for name in matchingNames

      when 'mousedown', 'touchstart'
        if @surface.el.style.cursor is PREFIXED_GRAB
          @surface.el.style.cursor = PREFIXED_GRABBING
          document.body.cursor = document.body.cursor

        e.preventDefault() # Prevent the surface from starting a new tool.

        @select()

        @['on *start']?.call @, e

        moveEvent = if eventName is 'mousedown' then 'mousemove' else 'touchmove'
        endEvent = if eventName is 'mousedown' then 'mouseup' else 'touchend'

        if 'on *drag' of @
          @["on *drag"] e

          moveHandler = (e) =>
            @['on *drag'] e

          endHandler = =>
            document.removeEventListener moveEvent, moveHandler, false
            document.removeEventListener endEvent, endHandler, false

          document.addEventListener moveEvent, moveHandler, false
          document.addEventListener endEvent, endHandler, false

        for name in matchingNames then do (name) =>
          @["on *start #{name}"]?.call @, e

          if "on *drag #{name}" of @
            @["on *drag #{name}"] e

            namedMoveHandler = (e) =>
              @["on *drag #{name}"] e

            namedEndHandler = =>
              document.removeEventListener moveEvent, namedMoveHandler, false
              document.removeEventListener endEvent, namedEndHandler, false

            document.addEventListener moveEvent, namedMoveHandler, false
            document.addEventListener endEvent, namedEndHandler, false

      when 'mouseup', 'touchend'
        if @surface.el.style.cursor is PREFIXED_GRABBING
          @surface.el.style.cursor = PREFIXED_GRAB

        @['on *end']?.call @, e
        @["on *end #{name}"]?.call @, e

      when 'mouseout'
        @surface.el.style.cursor = ''

  select: ->
    return if @surface.disabled
    return if @surface.selection is @
    @root.toggleClass 'selected', true
    @root.toFront()
    @trigger 'select', arguments
    null

  deselect: ->
    @root.toggleClass 'selected', false
    @trigger 'deselect', arguments
    null

  destroy: =>
    @deselect()

    for eventName in POINTER_EVENTS
      @root.el.removeEventListener eventName, @handleEvents, false

    @root.remove()

    super
    null

  pointerOffset: ->
    @surface.pointerOffset arguments...

  initialize: ->
    # Add shapes here.
    # E.g. @mainHandle = @addShape 'circle'

  onFirstClick: ->
    # Usualy, defer to `onFirstDrag`.
    # E.g. @onFirstDrag arguments...

  onFirstDrag: ->
    # Usualy, defer to a more general on-drag method.
    # E.g. @['on drag mainHandle'] arguments...

  onFirstRelease: ->
    # Override this if you need to do some post-create procedure.

  render: ->
    # Reflect the state of the mark, e.g.:
    # @mainHandle.attr cx: @mark.x, cy: @mark.y
    # @controls.moveTo @mark.x, @mark.y

ToolControls.defaultStyle = insertStyle 'marking-surface-tool-default-style', '''
  .marking-tool-root {
    opacity: 0.5;
  }

  .marking-tool-root.selected {
    opacity: 1;
  }
'''
