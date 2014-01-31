BACKSPACE = 8
DELETE = 46

class MarkingSurface extends ElementBase
  className: 'marking-surface'
  tool: Tool
  selection: null
  disabled: false

  constructor: ->
    @tools = []
    @marks = []
    super

    @addEvent 'keydown', @onKeyDown

    @svgContainer = new ElementBase className: 'marking-surface-svg-container'
    @svgContainer.addEvent 'mousedown', @onStart
    @svgContainer.addEvent 'touchstart', @onTouchStart

    @svg = new SVG
    @svgRoot = @svg.addShape 'g.svg-root'

    @svgContainer.el.appendChild @svg.el
    @el.appendChild @svgContainer.el

    @toolControlsContainer = document.createElement 'div'
    @toolControlsContainer.className = 'marking-surface-tool-controls-container'
    @el.appendChild @toolControlsContainer

    @disable() if @disabled

  disable: (e) ->
    @selection?.deselect()
    super

  pointerOffset: (e) ->
    {x, y} = ElementBase::pointerOffset.apply @svg, arguments
    if @svg.el.hasAttribute 'viewBox'
      viewBox = @svg.el.viewBox.animVal
      x += viewBox.x
      x *= viewBox.width / @svg.el.offsetWidth
      y += viewBox.y
      y *= viewBox.height / @svg.el.offsetHeight
    {x, y}

  physicalOffset: ({x, y}) ->
    if @svg.el.hasAttribute 'viewBox'
      viewBox = @svg.el.viewBox.animVal
      x /= viewBox.width / @svg.el.offsetWidth
      x -= viewBox.x
      y /= viewBox.height / @svg.el.offsetHeight
      y -= viewBox.y
    {x, y}

  onStart: (e) =>
    return if @disabled
    return if e.defaultPrevented
    return unless @tool?

    e.preventDefault()

    tool = if not @selection? or @selection?.isComplete()
      @addTool()
    else
      @selection

    tool.select()
    tool.onInitialClick e
    @triggerEvent 'tool-initial-click', tool

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
    @triggerEvent 'tool-initial-drag', @selection
    null

  onRelease: (e) =>
    e.preventDefault()
    @selection.onInitialRelease arguments...
    @triggerEvent 'tool-initial-release', @selection

    dragEvent = if e.type is 'mouseup' then 'mousemove' else 'touchmove'
    document.removeEventListener dragEvent, @onDrag, false
    document.removeEventListener e.type, @onRelease, false

    null

  onKeyDown: (e) =>
    return if @disabled
    return unless document.activeElement is @el
    return if e.altKey or e.ctrlKey

    if e.which in [BACKSPACE, DELETE]
      e.preventDefault()

      switch e.which
        when BACKSPACE, DELETE then @deleteSelection()

    null

  addTool: (tool) ->
    tool ?= new @tool surface: @

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
      @triggerEvent 'change-mark', tool.mark

    tool.mark.on 'destroy', =>
      @marks.splice (@marks.indexOf tool.mark), 1
      @trigger 'destroy-mark', [tool.mark]
      @trigger 'change', [tool.mark]
      @triggerEvent 'destroy-mark', tool.mark

    @marks.push tool.mark

    @trigger 'change', [tool.mark]

    tool

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
    @svgContainer.destroy()
    super

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
