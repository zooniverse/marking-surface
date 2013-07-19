class MarkingSurface extends BaseClass
  tool: Tool

  container: null
  className: 'marking-surface'
  tabIndex: 0

  svg: null
  width: NaN
  height: NaN

  zoomBy: 1
  zoomSnapTolerance: 0.05

  panX: 0
  panY: 0

  tools: null
  selection: null

  marks: null

  disabled: false

  constructor: (params = {}) ->
    super

    @container ?= document.createElement 'div'

    @container.className = @className
    @container.setAttribute 'tabindex', @tabIndex
    @container.setAttribute 'unselectable', true

    @container.addEventListener 'mousedown', @onMouseDown, false
    @container.addEventListener 'mousemove', @onMouseMove, false
    @container.addEventListener 'touchstart', @onTouchStart, false
    @container.addEventListener 'touchmove', @onTouchMove, false

    if @container.parentNode?
      @width ||= @container.clientWidth
      @height ||= @container.clientHeight

    @svg ?= new SVG {@width, @height}
    @svg.el.style.display = 'block' # This is okay since it's always contained.
    @container.appendChild @svg.el

    @marks ?= []
    @tools ?= []

    disable() if @disabled

  resize: (@width = @width, @height = @height) ->
    @svg.attr {@width, @height}
    null

  zoom: (@zoomBy = 1) ->
    @zoomBy = 1 if @zoomBy < 1 + @zoomSnapTolerance
    @pan()
    null

  pan: (@panX = @panX, @panY = @panY) ->
    @panX = Math.min @panX, @width, @width - (@width / @zoomBy)
    @panY = Math.min @panY, @height, @height - (@height / @zoomBy)

    @svg.attr 'viewBox', "#{@panX} #{@panY} #{@width / @zoomBy} #{@height / @zoomBy}"

    tool.render() for tool in @tools
    null

  onMouseMove: (e) =>
    return if @zoomBy is 1
    {x, y} = @pointerOffset e
    @panX = (@width - (@width / @zoomBy)) * (x / @width)
    @panY = (@height - (@height / @zoomBy)) * (y / @height)
    @pan()
    null

  onTouchStart: (e) =>
    @onMouseDown e if e.touches.length is 1
    null

  onTouchMove: (e) =>
    @onMouseMove e
    null

  onMouseDown: (e) =>
    return if @disabled
    return if e.defaultPrevented
    return if e.target in @container.querySelectorAll ".#{ToolControls::className}, .#{ToolControls::className} *"

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      if @tool?
        tool = new @tool surface: @
        mark = tool.mark

        @tools.push tool
        @marks.push mark

        tool.on 'select', =>
          return if @selection is tool

          @selection?.deselect()

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

    if tool?
      tool.select()
      tool.onInitialClick e

    dragEvent = if e.type is 'mousedown' then 'mousemove' else 'touchmove'
    releaseEvent = if e.type is 'mousedown' then 'mouseup' else 'touchend'
    document.addEventListener dragEvent, @onDrag, false
    document.addEventListener releaseEvent, @onRelease, false

    null

  onDrag: (e) =>
    e.preventDefault()

    @selection?.onInitialDrag arguments...
    null

  onRelease: (e) =>
    e.preventDefault()
    dragEvent = if e.type is 'mouseup' then 'mousemove' else 'touchmove'
    document.removeEventListener dragEvent, @onDrag, false
    document.removeEventListener e.type, @onRelease, false

    @selection?.onInitialRelease arguments...
    null

  disable: (e) ->
    return if @disabled
    @disabled = true
    @container.setAttribute 'disabled', 'disabled'
    @selection?.deselect()
    null

  enable: (e) ->
    return unless @disabled
    @disabled = false
    @container.removeAttribute 'disabled'
    null

  destroy: ->
    mark.destroy() for mark in @marks
    @container.removeEventListener 'mousedown', @onMouseDown, false
    @container.removeEventListener 'mousemove', @onMouseMove, false
    @container.removeEventListener 'touchstart', @onTouchStart, false
    @container.removeEventListener 'touchmove', @onTouchMove, false
    null

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    elements = []
    currentElement = @container
    while currentElement?
      elements.push currentElement
      currentElement = currentElement.parentNode

    left = 0
    top = 0

    for element in elements
      left += element.offsetLeft unless isNaN element.offsetLeft
      top += element.offsetTop unless isNaN element.offsetTop

    x = e.pageX - left
    y = e.pageY - top

    {x, y}
