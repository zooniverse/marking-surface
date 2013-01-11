$ = window.jQuery
Raphael = window.Raphael

doc = $(document)


class BaseClass
  _$: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @_$ = $(@)

  destroy: ->
    @trigger 'destroy'
    @off()

  for method in ['on', 'one', 'trigger', 'off'] then do (method) =>
    @::[method] = ->
      @_$[method] arguments...


class Mark extends BaseClass
  type: 'mark'

  set: (property, value, {fromMany} = {}) ->
    if typeof property is 'string'
      setter = @["set #{property}"]
      @[property] = if setter then setter.call @, value else value
    else
      map = property
      @set property, value, fromMany: true for property, value of map

    @trigger 'change' unless fromMany

  toJSON: ->
    {@type}


class Tool extends BaseClass
  @mark: Mark

  mark: null
  surface: null

  set: null

  constructor: ->
    super
    @set ?= @surface.paper.set()

    @mark.on 'change', @render

    setTimeout =>
      for eventName in ['mousedown', 'mousemove', 'mouseup']
        @set[eventName] $.proxy @, 'handleEvents'

  addShape: (type, params...) ->
    shape = @surface.paper[type.toLowerCase()] params...
    @set.push shape
    shape

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    doc.one 'mouseup touchend', (e) =>
      @trigger 'initial-drag', [e]

  onInitialDrag: (e) ->

  handleEvents: (e) ->
    type = e.type

    for name, shape of @ when shape in @set
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

  select: ->
    @set.toFront()
    @trigger 'tool-select', arguments

  deselect: ->
    @trigger 'tool-deselect', arguments

  destroy: ->
    super
    @set.remove()
    @deleteButton.remove()

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
    return if e.isDefaultPrevented()
    e.preventDefault()

    if not @selection? or @selection.isComplete()
      tool = new @tool
        mark: new @tool.mark
        surface: @

      @tools.push tool

      tool.on 'tool-select', =>
        @selection?.deselect()
        @selection = tool

      tool.on 'tool-deselect', =>
        @selection = null

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
