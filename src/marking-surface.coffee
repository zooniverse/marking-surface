BACKSPACE = 8
DELETE = 46
TAB = 9

class MarkingSurface extends BaseClass
  tool: Tool

  tagName: 'div'
  className: 'marking-surface'
  tabIndex: 0

  svg: null

  zoomBy: 1
  zoomSnapTolerance: 0.05
  panX: 0.5
  panY: 0.5

  tools: null
  selection: null

  marks: null

  disabled: false

  offsetAtLastMousedown: null

  constructor: ->
    super

    @el = document.querySelectorAll @el if typeof @el is 'string'
    @el ?= document.createElement @tagName
    toggleClass @el, @constructor::className, true
    toggleClass @el, @className, true
    @el.setAttribute 'tabindex', @tabIndex

    @el.addEventListener 'mousemove', @onMouseMove, false
    @el.addEventListener 'touchmove', @onTouchMove, false
    @el.addEventListener 'mousedown', @onMouseDown, false
    @el.addEventListener 'touchstart', @onTouchStart, false
    @el.addEventListener 'keydown', @onKeyDown, false

    @svg ?= new SVG
    @svgRoot ?= @svg.addShape 'g.svg-root'
    @el.appendChild @svg.el

    @marks ?= []
    @tools ?= []

    disable() if @disabled

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

  onMouseDown: (e) =>
    return if @disabled
    return if e.defaultPrevented
    return if e.target in @el.querySelectorAll ".#{ToolControls::className}, .#{ToolControls::className} *"

    e.preventDefault()

    # Presuming the element won't move mid-drag
    @offsetAtLastMousedown = @el.getBoundingClientRect()

    if not @selection? or @selection.isComplete()
      if @tool?
        tool = new @tool surface: @
        mark = tool.mark

        tool.on 'select', =>
          @el.focus()

          return if @selection is tool

          @selection?.deselect()

          removeFrom tool, @tools
          @tools.push tool

          @selection = tool
          @trigger 'select-tool', [@selection]

        tool.on 'deselect', =>
          @selection = null

        tool.on 'destroy', =>
          removeFrom tool, @tools
          @trigger 'destroy-tool', [tool]

        @tools.push tool
        @trigger 'create-tool', [tool]

        mark.on 'change', =>
          @trigger 'change', [mark]

        mark.on 'destroy', =>
          removeFrom mark, @marks
          @trigger 'destroy-mark', [mark]
          @trigger 'change', [mark]

        @marks.push mark
        @trigger 'create-mark', [mark]

        @trigger 'change'

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

  onTouchStart: (e) =>
    @onMouseDown e if e.touches.length is 1
    null

  onKeyDown: (e) =>
    return if @disabled
    return if e.altKey or e.ctrlKey
    return unless document.activeElement is @el

    switch e.which
      when BACKSPACE, DELETE
        e.preventDefault()
        @selection?.mark.destroy()

      when TAB
        e.preventDefault()
        if e.shiftKey
          @tools[0]?.select()

        else
          e.preventDefault()
          current = @selection
          next = @tools[Math.max 0, @tools.length - 2]

          if next?
            next.select()
            removeFrom current, @tools
            @tools.unshift current

    null

  getValue: ->
    JSON.stringify @marks

  addShape: ->
    @svgRoot.addShape arguments...

  disable: (e) ->
    @disabled = true
    @el.setAttribute 'disabled', 'disabled'
    @selection?.deselect()
    null

  enable: (e) ->
    @disabled = false
    @el.removeAttribute 'disabled'
    null

  reset: ->
    @marks[0].destroy() until @marks.length is 0
    # Tools destroy themselves with their marks.
    # Tool controls destroy themselves with their tools.

  destroy: ->
    @reset()
    @el.removeEventListener 'mousedown', @onMouseDown, false
    @el.removeEventListener 'mousemove', @onMouseMove, false
    @el.removeEventListener 'touchstart', @onTouchStart, false
    @el.removeEventListener 'touchmove', @onTouchMove, false
    @el.removeEventListener 'keydown', @onKeyDown, false
    super
    null

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    {left, top} = @offsetAtLastMousedown || @el.getBoundingClientRect()
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top

    {x, y}

MarkingSurface.defaultStyle = insertStyle 'marking-surface-default-style', '''
  .marking-surface-style-container {
    display: none;
  }

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
