MOUSE_EVENTS = '''
  mousedown mouseover mousemove mouseout mouseup
  touchstart touchmove touchend
'''.split /\s+/

class Tool extends BaseClass
  @Mark: Mark
  @Controls: ToolControls

  cursors: null

  mark: null
  markDefaults: null

  surface: null

  shapeSet: null
  controls: null

  clicks: 0

  renderFps: 30
  renderTimeout: NaN

  constructor: ->
    super

    @mark ?= new @constructor.Mark
    @mark.set @markDefaults if @markDefaults?

    @mark.on 'change', =>
      @onMarkChange arguments...

    @mark.on 'destroy', =>
      @destroy arguments...

    @shapeSet ?= @surface.paper.set()

    @controls = new @constructor.Controls tool: @
    @controls.el.appendTo @surface.container

    @initialize arguments...

  addShape: (type, params...) ->
    attributes = params.pop() if typeof params[params.length - 1] is 'object'

    shape = @surface.paper[type.toLowerCase()] params...
    shape.attr attributes

    for eventName in MOUSE_EVENTS
      shape[eventName] => @handleEvents arguments...

    @shapeSet.push shape
    shape

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    @onFirstClick e

  onInitialDrag: (e) ->
    @onFirstDrag e

  onInitialRelease: (e) ->
    @clicks += 1
    @trigger 'initial-release', [e]
    @onFirstRelease arguments...

  # Override this if drawing the tool requires multiple drag steps (e.g. axes).
  isComplete: ->
    @clicks is 1

  handleEvents: (e) ->
    return if @surface.disabled

    eventName = e.type
    target = e.target || e.srcElement # For IE
    shape = @surface.paper.getById target.raphaelid
    name = '*'

    for property, value of @
      isArray = value instanceof Array or value instanceof @shapeSet.constructor
      if (value is shape) or (isArray and shape in value)
        name = property

    @["on #{eventName}"]?.call @, e, shape

    @["on #{eventName} #{name}"]?.call @, e, shape

    switch eventName
      when 'mouseover'
        @surface.container.css cursor: @cursors?[name]

      when 'mouseout'
        @surface.container.css cursor: ''

      when 'mousedown', 'touchstart'
        e.preventDefault()
        @select()

        if 'on drag' of @
          onDrag = => @['on drag'] arguments..., shape
          doc.on 'mousemove touchmove', onDrag
          doc.one 'mouseup touchend', => doc.off 'mousemove touchmove', onDrag

        if name and "on drag #{name}" of @
          onNamedDrag = => @["on drag #{name}"] arguments..., shape
          doc.on 'mousemove touchmove', onNamedDrag
          doc.one 'mouseup touchend', => doc.off 'mousemove touchmove', onNamedDrag

  mouseOffset: ->
    @surface.mouseOffset arguments...

  onMarkChange: ->
    return if @renderTimeout
    @renderTimeout = setTimeout (=> @render arguments...; @renderTimeout = NaN), 1000 / @renderFps

  select: ->
    @shapeSet.attr opacity: 1
    @shapeSet.toFront()
    @trigger 'select', arguments

  deselect: ->
    @shapeSet.attr opacity: 0.5
    @trigger 'deselect', arguments

  destroy: ->
    super

    @surface.container.focus()
    @shapeSet.animate
      opacity: 0
      r: 0
      'stroke-width': 0
      250
      'ease-in'
      =>
        @shapeSet.remove() # This also unbinds all events.

  initialize: ->
    # E.g.
    # @addShape 'circle'

  onFirstClick: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  onFirstDrag: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  onFirstRelease: (e) ->

  render: ->
    # E.g.
    # @shapeSet.attr cx: @mark.position
    # @controls.moveTo @mark.position, @mark.position
