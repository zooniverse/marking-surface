$ = window.jQuery
Raphael = window.Raphael

doc = $(document)


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
      for eventName in ['mousedown', 'mousemove', 'mouseup']
        @shapeSet[eventName] $.proxy @, 'handleEvents'

  addShape: (type, params...) ->
    shape = @surface.paper[type.toLowerCase()] params...
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

    for name, shape of @ when shape in @shapeSet
      break if shape.node is e.target
      name = ''
      shape = null

    @["on #{type}"]?.call @, arguments...
    @["on #{type} #{name}"]?.call @, arguments... if name

    if type in ['mousedown', 'touchstart']
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

  'on mousedown': (e) ->
    @select()
    e.preventDefault()

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

  paper: null
  marks: null
  tools: null

  selection: null

  disabled: false

  constructor: (params = {}) ->
    super
    @container ?= document.createElement 'div'
    @container = $(@container)
    @container.addClass @className
    @width = @container.width() || @width unless 'width' of params
    @height = @container.height() || @height unless 'height' of params

    @paper ?= Raphael @container.get(0), @width, @height

    @marks ?= []
    @tools ?= []

    disable() if @disabled

    @container.on 'mousedown touchstart', $.proxy @, 'onMouseDown'

  onMouseDown: (e) ->
    return if @disabled
    return unless e.target in [@container.get(0), @paper.canvas]
    return if e.isDefaultPrevented()

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      tool = new @tool surface: @
      mark = tool.mark

      @tools.push tool
      @marks.push mark

      tool.on 'selected', =>
        @selection?.deselect()
        @selection = tool

      tool.on 'deselected', =>
        @selection = null

      tool.on 'destroyed', =>
        index = @tools.indexOf tool
        @tools.splice index, 1

      mark.on 'destroyed', =>
        index = @marks.indexOf mark
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
    e = e.originalEvent if 'originalEvent' of e
    e = e.touches[0] if 'touches' of e
    {left, top} = @container.offset()
    x: e.pageX - left, y: e.pageY - top


MarkingSurface.Mark = Mark
MarkingSurface.Tool = Tool

module.exports = MarkingSurface
