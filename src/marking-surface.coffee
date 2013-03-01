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
  panX: 0
  panY: 0

  selection: null

  disabled: false

  constructor: (params = {}) ->
    super

    @container ?= document.createElement 'div'
    @container = $(@container)
    @container.addClass @className
    @container.attr tabindex: 0, unselectable: true
    @container.on 'blur', => @onBlur arguments...
    @container.on 'focus', => @onFocus arguments...

    unless @container.parents().length is 0
      @width = @container.width() || @width unless 'width' of params
      @height = @container.height() || @height unless 'height' of params

    @paper ?= Raphael @container.get(0), @width, @height
    @image = @paper.image 'about:blank', 0, 0, @width, @height

    setTimeout => @image.attr src: @background

    @marks ?= []
    @tools ?= []

    disable() if @disabled

    @container.on START, => @onMouseDown arguments...
    @container.on MOVE, => @onMouseMove arguments...
    @container.on 'keydown', => @onKeyDown arguments...

  resize: (@width, @height) ->
    @paper.setSize @width, @height
    @image.attr {@width, @height}

  zoom: (@zoomBy = 1) ->
    @pan()

  pan: (@panX = @panX, @panY = @panY) ->
    @panX = Math.min @panX, @width, @width - (@width / @zoomBy)
    @panY = Math.min @panY, @height, @height - (@height / @zoomBy)

    @paper.setViewBox @panX, @panY, @width / @zoomBy, @height / @zoomBy

    tool.render() for tool in @tools

  onMouseMove: (e) ->
    return if @zoomBy is 1
    {x, y} = @mouseOffset e
    @panX = (@width - (@width / @zoomBy)) * (x / @width)
    @panY = (@height - (@height / @zoomBy)) * (y / @height)
    @pan()

  onMouseDown: (e) ->
    return if @disabled
    return unless e.target in [@container.get(0), @paper.canvas, @image.node]
    return if e.isDefaultPrevented()

    e.preventDefault()

    $(document.activeElement).blur()
    @container.focus()

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
        @trigger 'destroy-mark', [mark]

      tool.select()
      @trigger 'create-mark', [mark, tool]

    else
      tool = @selection

    tool.select()
    tool.onInitialClick e

    onDrag = => @onDrag arguments...
    doc.on MOVE, onDrag
    doc.one END, =>
      @onRelease arguments...
      doc.off MOVE, onDrag

  onDrag: (e) ->
    e.preventDefault()
    @selection.onInitialDrag e

  onRelease: (e) ->
    e.preventDefault()
    @selection.onInitialRelease e

  onKeyDown: (e) ->
    return if $(e.target).is 'input, textarea, select, button'

    if e.which in [BACKSPACE, DELETE]
      e.preventDefault()
      @selection?.mark.destroy()
    else if e.which is TAB and @selection?
      e.preventDefault()

      if e.shiftKey
        @tools.unshift @tools.pop()
      else
        @tools.push @tools.shift()

      @tools[@tools.length - 1]?.select()

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
