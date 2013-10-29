BACKSPACE = 8
DELETE = 46
TAB = 9

class MarkingSurface extends ElementBase
  tool: Tool

  className: 'marking-surface'
  tabIndex: 0

  zoomBy: 1
  zoomSnapTolerance: 0.05
  panX: 0.5
  panY: 0.5

  selection: null

  constructor: ->
    super
    @tools = []
    @marks = []

    @el.setAttribute 'tabindex', @tabIndex

    @addEvent 'mousedown', @onStart
    @addEvent 'touchstart', @onTouchStart
    @addEvent 'mousemove', @onMouseMove
    @addEvent 'touchmove', @onTouchMove
    @addEvent 'keydown', @onKeyDown

    @svg = new SVG
    @svgRoot = @svg.addShape 'g.svg-root'
    @el.appendChild @svg.el

    @toolControlsContainer = document.createElement 'div'
    @toolControlsContainer.className = 'marking-surface-tool-controls-container'
    @el.appendChild @toolControlsContainer

  zoom: (@zoomBy = 1) ->
    if @zoomBy < 1 + @zoomSnapTolerance
      @zoomBy = 1
      @panX = @constructor::panX
      @panY = @constructor::panY

    @pan()
    null

  pan: (@panX = @panX, @panY = @panY) ->
    minX = (@el.clientWidth - (@el.clientWidth / @zoomBy)) * @panX
    minY = (@el.clientHeight - (@el.clientHeight / @zoomBy)) * @panY
    width = @el.clientWidth / @zoomBy
    height = @el.clientHeight / @zoomBy

    @svg.attr 'viewBox', "#{minX} #{minY} #{width} #{height}"

    tool.render() for tool in @tools
    null

  onMouseMove: (e) =>
    return if @zoomBy is 1
    {x, y} = @pointerOffset e
    @pan x / @el.clientWidth, y / @el.clientHeight
    null

  onTouchMove: (e) =>
    @onMouseMove e # if e.touches.length is 2
    null

  onStart: (e) =>
    return if @disabled
    return if e.defaultPrevented
    return unless @tool?
    return if e.target in @el.querySelectorAll ".#{ToolControls::className}"
    return if e.target in @el.querySelectorAll ".#{ToolControls::className} *"

    e.preventDefault()

    tool = if not @selection? or @selection?.isComplete()
      @createTool()
    else
      @selection

    tool.select()
    tool.onInitialClick e

    dragEvent = if e.type is 'mousedown' then 'mousemove' else 'touchmove'
    document.addEventListener dragEvent, @onDrag, false

    releaseEvent = if e.type is 'mousedown' then 'mouseup' else 'touchend'
    document.addEventListener releaseEvent, @onRelease, false

    null

  onTouchStart: (e) =>
    @onStart e if e.touches.length is 1
    null

  onDrag: (e) =>
    e.preventDefault()
    @selection.onInitialDrag arguments...
    null

  onRelease: (e) =>
    e.preventDefault()
    @selection.onInitialRelease arguments...

    dragEvent = if e.type is 'mouseup' then 'mousemove' else 'touchmove'
    document.removeEventListener dragEvent, @onDrag, false
    document.removeEventListener e.type, @onRelease, false

    null

  onKeyDown: (e) =>
    return if @disabled
    return unless document.activeElement is @el
    return if e.altKey or e.ctrlKey

    if e.which in [BACKSPACE, DELETE, TAB]
      e.preventDefault()

      switch e.which
        when BACKSPACE, DELETE then @deleteSelection()
        when TAB then @tabSelectNext e.shiftKey

    null

  createTool: ->
    tool = new @tool surface: @

    tool.on 'select', =>
      @el.focus()

      return if @selection is tool

      @selection?.deselect()

      @selection = tool

      @tools.splice (@tools.indexOf @selection), 1
      @tools.push @selection

      @trigger 'select-tool', [@selection]

    tool.on 'deselect', =>
      @selection = null
      @trigger 'deselect-tool', [@selection]

    tool.on 'destroy', =>
      @tools.splice (@tools.indexOf tool), 1
      @trigger 'destroy-tool', [tool]

    @tools.push tool
    @trigger 'create-tool', [tool]

    tool.mark.on 'change', =>
      @trigger 'change-mark', [tool.mark]
      @trigger 'change', [tool.mark]

    tool.mark.on 'destroy', =>
      @marks.splice (@marks.indexOf tool.mark), 1
      @trigger 'destroy-mark', [tool.mark]
      @trigger 'change', [tool.mark]

    @marks.push tool.mark
    @trigger 'create-mark', [tool.mark]

    @trigger 'change', [tool.mark]

    tool

  tabSelectNext: (reverse) ->
    if reverse
      @tools[0]?.select()
    else
      current = @selection
      next = @tools[Math.max 0, @tools.length - 2]

      if next?
        next.select()

        if current?
          @tools.splice (@tools.indexOf current), 1
          @tools.unshift current

    null

  addShape: ->
    @svgRoot.addShape arguments...

  deleteSelection: ->
    @selection?.mark.destroy()
    null

  getValue: ->
    JSON.stringify @marks

  disable: ->
    @selection?.deselect()
    super
    null

  reset: ->
    # Tools destroy themselves with their marks.
    # Tool controls destroy themselves with their tools.
    @marks[0].destroy() until @marks.length is 0
    null

  destroy: ->
    @reset()
    super
    null

MarkingSurface.defaultStyle = insertStyle 'marking-surface-default-style', '''
  .marking-surface {
    display: inline-block;
    position: relative;
  }

  .marking-surface > svg {
    display: block;
    height: 100%;
    width: 100%;
  }

  .marking-surface-tool-controls-container {
    left: 0;
    position: absolute;
    top: 0;
  }
'''
