BACKSPACE = 8
DELETE = 46
TAB = 9

class MarkingSurface extends BaseClass
  tool: Tool

  tagName: 'div'
  className: 'marking-surface'
  tabIndex: 0

  zoomBy: 1
  zoomSnapTolerance: 0.05
  panX: 0.5
  panY: 0.5

  disabled: false

  selection: null
  offsetAtLastMousedown: null

  constructor: ->
    super

    @el = document.querySelector @el if typeof @el is 'string'
    @el ?= document.createElement @tagName
    @el.setAttribute 'tabindex', @tabIndex

    toggleClass @el, MarkingSurface::className, true
    toggleClass @el, @constructor::className, true unless @constructor::className is MarkingSurface.className
    toggleClass @el, @className, true unless @className is @constructor::className

    @el.addEventListener 'mousedown', @onStart, false
    @el.addEventListener 'touchstart', @onTouchStart, false
    @el.addEventListener 'mousemove', @onMouseMove, false
    @el.addEventListener 'touchmove', @onTouchMove, false
    @el.addEventListener 'keydown', @onKeyDown, false

    @svg = new SVG
    @svgRoot = @svg.addShape 'g.svg-root'
    @el.appendChild @svg.el

    @marks ?= []
    @tools ?= []

    @disable() if @disabled

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
    return unless @tool?
    return if e.defaultPrevented
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

  onTouchStart: (e) =>
    @onStart e if e.touches.length is 1
    null

  onKeyDown: (e) =>
    return if @disabled
    return if e.altKey or e.ctrlKey
    return unless document.activeElement is @el

    switch e.which
      when BACKSPACE, DELETE
        e.preventDefault()
        @deleteSelection()

      when TAB
        e.preventDefault()
        @tabSelect e.shiftKey

    null

  createTool: ->
    tool = new @tool surface: @

    tool.on 'select', =>
      @el.focus()

      return if @selection is tool

      @selection?.deselect()

      @selection = tool
      removeFrom @selection, @tools
      @tools.push @selection

      @trigger 'select-tool', [@selection]

    tool.on 'deselect', =>
      @selection = null

    tool.on 'destroy', =>
      removeFrom tool, @tools
      @trigger 'destroy-tool', [tool]

    @tools.push tool
    @trigger 'create-tool', [tool]

    tool.mark.on 'change', =>
      @trigger 'change', [tool.mark]

    tool.mark.on 'destroy', =>
      removeFrom tool.mark, @marks
      @trigger 'destroy-mark', [tool.mark]
      @trigger 'change', [tool.mark]

    @marks.push tool.mark
    @trigger 'create-mark', [tool.mark]

    @trigger 'change'

    tool

  tabSelect: (reverse) ->
    if reverse
      @tools[0]?.select()
    else
      current = @selection
      next = @tools[Math.max 0, @tools.length - 2]

      if next?
        next.select()

        if current?
          removeFrom current, @tools
          @tools.unshift current

    null

  deleteSelection: ->
    @selection?.mark.destroy()
    null

  addShape: ->
    @svgRoot.addShape arguments...

  disable: (e) ->
    @disabled = true
    @selection?.deselect()
    @el.setAttribute 'disabled', 'disabled'
    null

  enable: (e) ->
    @disabled = false
    @el.removeAttribute 'disabled'
    null

  getValue: ->
    JSON.stringify @marks

  reset: ->
    @marks[0].destroy() until @marks.length is 0
    # Tools destroy themselves with their marks.
    # Tool controls destroy themselves with their tools.

  destroy: ->
    @reset()
    @el.removeEventListener 'mousedown', @onStart, false
    @el.removeEventListener 'mousemove', @onMouseMove, false
    @el.removeEventListener 'touchstart', @onTouchStart, false
    @el.removeEventListener 'touchmove', @onTouchMove, false
    @el.removeEventListener 'keydown', @onKeyDown, false
    super
    null

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    {left, top} = @el.getBoundingClientRect()
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top

    {x, y}

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
'''
