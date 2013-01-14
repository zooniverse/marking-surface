$ = window.jQuery
Raphael = window.Raphael

doc = $(document)
body = $(document.body)


class BaseClass
  jQueryInstance: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @jQueryInstance = $(@)

  destroy: ->
    @trigger 'destroyed'
    @off()

  for method in ['on', 'one', 'trigger', 'off'] then do (method) =>
    @::[method] = ->
      @jQueryInstance[method] arguments...


class Mark extends BaseClass
  set: (property, value, {fromMany} = {}) ->
    if typeof property is 'string'
      setter = @["set #{property}"]
      @[property] = if setter then setter.call @, value else value

    else
      map = property
      @set property, value, fromMany: true for property, value of map

    @trigger 'change', property, value unless fromMany

  toJSON: ->
    result = {@type}

    for own property, value of @
      continue if property[...'jQuery'.length] is 'jQuery'
      result[property] = value

    result


class Tool extends BaseClass
  @Mark: Mark

  markDefaults: null
  surface: null

  cursors: null

  shapeSet: null

  constructor: ->
    super
    @shapeSet ?= @surface.paper.set()

    @mark ?= new @constructor.Mark
    @mark.set @markDefaults if @markDefaults
    @mark.on 'change', $.proxy @, 'render'
    @mark.on 'destroyed', $.proxy @, 'destroy'

    @deleteButton = $('<button name="delete-button">&times;</button>')
    @deleteButton.on 'click', $.proxy @, 'onClickDelete'
    @deleteButton.appendTo @surface.container

    setTimeout =>
      for eventName in ['mousedown', 'mouseover', 'mousemove', 'mouseout', 'mouseup']
        @shapeSet[eventName] $.proxy @, 'handleEvents'

  addShape: (type, params...) ->
    if typeof params[params.length - 1] is 'object'
      attributes = params.pop()

    shape = @surface.paper[type.toLowerCase()] params...
    shape.attr attributes
    @shapeSet.push shape
    shape

  onClickDelete: (e) ->
    @mark.destroy()

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    doc.one 'mouseup touchend', (e) =>
      @trigger 'initial-drag', [e]

  onInitialDrag: (e) ->
    # Override this to change some value of the mark.

  handleEvents: (e) ->
    type = e.type
    target = e.target || e.srcElement

    for name, shape of @ when shape in @shapeSet
      break if shape.node is target
      name = ''
      shape = null

    @["on #{type}"]?.call @, arguments...
    @["on #{type} #{name}"]?.call @, arguments... if name

    if type is 'mouseover'
      setTimeout =>
        body.css cursor: @cursors[name]

    if type is 'mouseout'
      body.css cursor: ''

    if type in ['mousedown', 'touchstart']
      @select()
      e.preventDefault()

      onDrag = $.proxy @, 'on drag' if 'on drag' of @
      onNamedDrag = $.proxy @, "on drag #{name}" if "on drag #{name}" of @

      if onDrag?
        doc.on 'mousemove touchmove', onDrag
        doc.one 'mouseup touchend', =>
          doc.off 'mousemove touchmove', onDrag

      if onNamedDrag?
        doc.on 'mousemove touchmove', onNamedDrag
        doc.one 'mouseup touchend', =>
          doc.off 'mousemove touchmove', onNamedDrag

  render: ->
    # Override this to redraw the shape based on the current state of the mark.

  select: ->
    @shapeSet.toFront()
    @trigger 'selected', arguments

  deselect: ->
    @trigger 'deselected', arguments

  destroy: ->
    @shapeSet.animate
      transform: '...s0.01'
      250
      'ease-out'
      =>
        @shapeSet.remove()
        @deleteButton.remove()

    super

  isComplete: ->
    true


class MarkingSurface extends BaseClass
  tool: Tool
  container: null
  className: 'marking-surface'
  width: 480
  height: 320
  background: ''

  paper: null
  image: null
  marks: null
  tools: null

  selection: null

  disabled: false

  constructor: (params = {}) ->
    super

    @container ?= document.createElement 'div'
    @container = $(@container)
    @container.addClass @className
    @container.attr tabindex: 0

    unless @container.parents().length is 0
      @width = @container.width() || @width unless 'width' of params
      @height = @container.height() || @height unless 'height' of params

    @paper ?= Raphael @container.get(0), @width, @height
    @image = @paper.image @background, 0, 0, @width, @height

    @marks ?= []
    @tools ?= []

    disable() if @disabled

    @container.on 'mousedown touchstart', $.proxy @, 'onMouseDown'
    @container.on 'keydown', $.proxy @, 'onKeyDown'

  onMouseDown: (e) ->
    return if @disabled
    @container.focus()

    return unless e.target in [@container.get(0), @paper.canvas, @image.node]
    return if e.isDefaultPrevented()

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      tool = new @tool surface: @
      mark = tool.mark

      @tools.push tool
      @marks.push mark

      tool.on 'selected', =>
        @selection?.deselect()

        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools.push tool

        @selection = tool

      tool.on 'deselected', =>
        @selection = null

      tool.on 'destroyed', =>
        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools[@tools.length - 1]?.select() if tool is @selection

      mark.on 'destroyed', =>
        index = i for m, i in @marks when m is mark
        @marks.splice index, 1

      tool.select()

    else
      tool = @selection

    tool.onInitialClick e

    doc.on 'mousemove touchmove', $.proxy @, 'onDrag'
    doc.one 'mouseup touchend', =>
      doc.off 'mousemove touchmove', $.proxy @, 'onDrag'

  onDrag: (e) ->
    @selection.onInitialDrag e

  onKeyDown: (e) ->

    if e.which in [8, 46] # Backspace and delete
      e.preventDefault()
      @selection?.mark.destroy()

  disable: (e) ->
    @disabled = true
    @container.attr disabled: true
    @container.addClass 'disabled'

  enable: (e) ->
    @disabled = false
    @container.attr disabled: false
    @container.removeClass 'disabled'

  destroy: ->
    mark.destroy() for mark in @marks
    super

  mouseOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent
    {left, top} = @container.offset()
    x: e.pageX - left, y: e.pageY - top


MarkingSurface.Mark = Mark
MarkingSurface.Tool = Tool

window.MarkingSurface = MarkingSurface
module.exports = MarkingSurface if module?
