$ = window.jQuery
Raphael = window.Raphael

win = $(window)
doc = $(document)
body = $(document.body)

MOUSE_EVENTS = ['mousedown', 'mouseover', 'mousemove', 'mouseout', 'mouseup']


class BaseClass
  jQueryEventProxy: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @jQueryEventProxy = $({})

  destroy: ->
    @trigger 'destroy'
    @off()

  for method in ['on', 'one', 'trigger', 'off'] then do (method) =>
    @::[method] = -> @jQueryEventProxy[method] arguments...


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
    result = {}

    for property, value of @
      continue if property is 'jQueryEventProxy'
      continue if typeof value is 'function'
      result[property] = value

    result


class Tool extends BaseClass
  @Mark: Mark

  cursors: null

  mark: null
  markDefaults: null

  surface: null
  shapeSet: null

  constructor: ->
    super

    @mark ?= new @constructor.Mark
    @mark.set @markDefaults if @markDefaults?
    @mark.on 'change', => @render arguments...
    @mark.on 'destroy', => @destroy arguments...

    @deleteButton = $('<button name="delete-button">&times;</button>')
    @deleteButton.css position: 'absolute'
    @deleteButton.on 'click', => @onClickDelete arguments...
    @deleteButton.appendTo @surface.container

    @shapeSet ?= @surface.paper.set()

    # Wait for shapes to be added in an overridden constructor.
    setTimeout =>
      for eventName in MOUSE_EVENTS
        @shapeSet[eventName] => @handleEvents arguments...

  addShape: (type, params...) ->
    attributes = params.pop() if typeof params[params.length - 1] is 'object'

    shape = @surface.paper[type.toLowerCase()] params...
    shape.attr attributes

    @shapeSet.push shape
    shape

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    @onFirstClick e

  onInitialDrag: (e) ->
    doc.one 'mouseup touchend', (e) => @trigger 'initial-drag', [e]
    @onFirstDrag e

  # Override this if drawing the tool requires multiple drag steps (e.g. axes).
  isComplete: ->
    true

  handleEvents: (e) ->
    return if @surface.disabled

    type = e.type
    target = e.target || e.srcElement

    for name, shape of @
      break if shape?.node is target
      name = ''
      shape = null

    shape ?= target

    @["on #{type}"]?.call @, e, shape
    @["on #{type} #{name}"]?.call @, e, shape if name

    if type is 'mouseover'
      setTimeout =>
        body.css cursor: @cursors?[name] || @cursors?['*'] || ''

    if type is 'mouseout'
      body.css cursor: ''

    if type in ['mousedown', 'touchstart']
      e.preventDefault()

      @select()

      if 'on drag' of @
        onDrag = => @['on drag'] arguments..., shape
        doc.on 'mousemove touchmove', onDrag
        doc.one 'mouseup touchend', =>
          doc.off 'mousemove touchmove', onDrag

      if name and "on drag #{name}" of @
        onNamedDrag = => @["on drag #{name}"] arguments..., shape
        doc.on 'mousemove touchmove', onNamedDrag
        doc.one 'mouseup touchend', =>
          doc.off 'mousemove touchmove', onNamedDrag

  onClickDelete: (e) ->
    @mark.destroy()

  select: ->
    @shapeSet.attr opacity: 1
    @deleteButton.show()
    @shapeSet.toFront()
    @trigger 'select', arguments

  deselect: ->
    @shapeSet.attr opacity: 0.5
    @deleteButton.hide()
    @trigger 'deselect', arguments

  destroy: ->
    @deleteButton.off()

    @shapeSet.animate
      opacity: 0
      r: 0
      'stroke-width': 0
      250
      'ease-in'
      =>
        @shapeSet.remove() # This also unbinds all events.
        @deleteButton.remove()
        super

  mouseOffset: ->
    @surface.mouseOffset arguments...

  onFirstClick: (e) ->
    # @mark.set position: @mouseOffset(e).x

  onFirstDrag: (e) ->
    # @mark.set position: @mouseOffset(e).x

  render: ->
    # @shapeSet.attr cx: @mark.position


class MarkingSurface extends BaseClass
  tool: Tool

  container: null
  className: 'marking-surface'
  width: 400
  height: 300
  background: ''

  paper: null
  image: null
  marks: null
  tools: null

  zoomBy: 1
  zoomX: 0
  zoomY: 0

  selection: null

  disabled: false

  constructor: (params = {}) ->
    super

    @container ?= document.createElement 'div'
    @container = $(@container)
    @container.addClass @className
    @container.attr tabindex: 0
    @container.on 'blur', => @onBlur arguments...
    @container.on 'focus', => @onFocus arguments...

    unless @container.parents().length is 0
      @width = @container.width() || @width unless 'width' of params
      @height = @container.height() || @height unless 'height' of params

    @paper ?= Raphael @container.get(0), @width, @height
    @image = @paper.image @background, 0, 0, @width, @height

    @marks ?= []
    @tools ?= []

    disable() if @disabled

    @container.on 'mousedown touchstart', => @onMouseDown arguments...
    @container.on 'mousemove touchmove', => @onMouseMove arguments...
    @container.on 'keydown', => @onKeyDown arguments...

  resize: (@width, @height) ->
    @paper.setSize @width, @height
    @image.attr {@width, @height}

  zoom: (@zoomBy = @zoomBy, @zoomX = @zoomX, @zoomY = @zoomY) ->
    @zoomX = Math.min @width, @zoomX
    @zoomY = Math.min @height, @zoomY
    @paper.setViewBox @zoomX, @zoomY, @width / @zoomBy, @height / @zoomBy
    tool.render() for tool in @tools

  onMouseMove: (e) ->
    return if @zoomBy is 1
    {x, y} = @mouseOffset e
    @zoomX = (@width - (@width / @zoomBy)) * (x / @width)
    @zoomY = (@height - (@height / @zoomBy)) * (y / @height)
    @zoom()

  onMouseDown: (e) ->
    return if @disabled
    return unless e.target in [@container.get(0), @paper.canvas, @image.node]
    return if e.isDefaultPrevented()

    @container.focus()

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      tool = new @tool surface: @
      mark = tool.mark

      @tools.push tool
      @marks.push mark

      tool.on 'select', =>
        @selection?.deselect() unless @selection is tool

        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools.push tool

        @selection = tool

      tool.on 'deselect', =>
        @selection = null

      tool.on 'destroy', =>
        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools[@tools.length - 1]?.select() if tool is @selection

      mark.on 'destroy', =>
        index = i for m, i in @marks when m is mark
        @marks.splice index, 1

      tool.select()

    else
      tool = @selection

    tool.select()
    tool.onInitialClick e

    onDrag = => @onDrag arguments...
    doc.on 'mousemove touchmove', onDrag
    doc.one 'mouseup touchend', =>
      doc.off 'mousemove touchmove', onDrag

  onDrag: (e) ->
    @selection.onInitialDrag e

  onKeyDown: (e) ->
    if e.which in [8, 46] # Backspace and delete
      e.preventDefault()
      @selection?.mark.destroy()

  onFocus: ->
    @selection?.select()

  onBlur: ->
    return if @container.has document.activeElement
    @selection?.deselect()

  disable: (e) ->
    @disabled = true
    @container.attr disabled: true
    @container.addClass 'disabled'
    @selection?.deselect()

  enable: (e) ->
    @disabled = false
    @container.attr disabled: false
    @container.removeClass 'disabled'

  destroy: ->
    @container.off().remove()
    mark.destroy() for mark in @marks
    super

  mouseOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent
    {left, top} = @container.offset()
    left += parseFloat @container.css 'padding-left'
    left += parseFloat @container.css 'border-left-width'
    top += parseFloat @container.css 'padding-top'
    top += parseFloat @container.css 'border-top-width'
    x: e.pageX - left, y: e.pageY - top


MarkingSurface.Mark = Mark
MarkingSurface.Tool = Tool

window.MarkingSurface = MarkingSurface
module.exports = MarkingSurface if module?
