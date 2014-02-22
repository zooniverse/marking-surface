class MarkingSurface extends ElementBase
  tag: 'div.marking-surface'
  focusable: true
  inputName: ''

  tool: null # This is the class with which to create new tools.

  selection: null

  constructor: ->
    @tools = []
    super

    @svg = new SVG tag: 'svg.marking-surface-svg'
    @sizeRect = @svg.addShape 'rect', fill: 'none', stroke: 'transparent', strokeWidth: 0, width: '100%', height: '100%'
    @root = @svg.addShape 'g.marking-surface-svg-root'
    @el.appendChild @svg.el
    @on 'destroy', [@svg, 'destroy']

    @svg.addEvent 'select', '.marking-surface-tool', [@, 'onSelectTool']
    @svg.addEvent 'change', '.marking-surface-tool', [@, 'onChangeMark']
    @svg.addEvent 'deselect', '.marking-surface-tool', [@, 'onDeselectTool']
    @svg.addEvent 'destroy', '.marking-surface-tool', [@, 'onDestroyTool']

    if @focusable
      @toolFocusTargetsContainer = new ElementBase tag: 'div.marking-surface-tool-focusables-container'
      @el.appendChild @toolFocusTargetsContainer.el
      @on 'destroy', [@toolFocusTargetsContainer, 'destroy']

    @toolControlsContainer = new ElementBase tag: 'div.marking-surface-tool-controls-container'
    @el.appendChild @toolControlsContainer.el
    @on 'destroy', [@toolControlsContainer, 'destroy']

    if @inputName
      @input = new ElementBase tag: 'input.marking-surface-input'
      @input.el.tabIndex = -1
      @input.el.name = @inputName
      @on 'change', @onChange
      @on 'destroy', [@input, 'destroy']
      @el.appendChild @input.el

    @trigger 'change'

    addEventListener 'resize', @, false

  handleEvent: (e) ->
    if e.target is window and e.type is 'resize'
      @rescaleTools()
    else
      super

  addShape: ->
    @root.addShape arguments...

  _onStart: (e) ->
    return if e.defaultPrevented # The event bubbled up from a tool's shape.
    return if matchesSelector e.target, '.marking-surface-tool-controls-container *'

    e.preventDefault()

    tool = if not @selection? or @selection?.isComplete()
      if @tool?
        @addTool()
    else
      @selection

    if tool?
      tool.select()
      tool.onInitialStart e

      super

  _onMove: (e) ->
    super
    @selection?.onInitialMove e

  _onRelease: (e) ->
    super
    @selection?.onInitialRelease e

  addTool: (tool) ->
    tool ?= new @tool markingSurface: @
    tool.markingSurface = @
    @tools.push tool
    tool.remove()
    @root.el.appendChild tool.el
    tool.render?()

    if tool.controls?
      @toolControlsContainer.el.appendChild tool.controls.el

    if tool.focusTarget?
      @toolFocusTargetsContainer?.el.appendChild tool.focusTarget.el

    @trigger 'add-tool', [tool]
    @trigger 'change'
    tool

  onSelectTool: (e) ->
    [tool] = e.detail
    unless @selection is tool
      @selection?.deselect()
      @selection = tool
      @trigger 'select-tool', [@selection]

  onChangeMark: (e) ->
    [mark] = e.detail
    @trigger 'change', [mark]

  onChange: ->
    @input?.el.value = @getValue()

  onDeselectTool: (e) ->
    [tool] = e.detail
    if @selection is tool
      @selection = null
      @trigger 'deselect-tool', [tool]

  onDestroyTool: (e) ->
    [tool] = e.detail
    index = @tools.indexOf tool
    @tools.splice index, 1
    @trigger 'remove-tool', [tool]
    @trigger 'change'

  toScale: ({x, y}) ->
    if @svg.el.hasAttribute 'viewBox'
      viewBox = @svg.el.viewBox.animVal
      sizeRect = @sizeRect.el.getBoundingClientRect()
      x += viewBox.x
      x *= viewBox.width / sizeRect.width
      y += viewBox.y
      y *= viewBox.height / sizeRect.height
    {x, y}

  toPixels: ({x, y}) ->
    if @svg.el.hasAttribute 'viewBox'
      viewBox = @svg.el.viewBox.animVal
      sizeRect = @sizeRect.el.getBoundingClientRect()
      x /= viewBox.width / sizeRect.width
      x -= viewBox.x
      y /= viewBox.height / sizeRect.height
      y -= viewBox.y
    {x, y}

  rescale: (x, y, width, height) ->
    @svg.attr 'viewBox', "#{x} #{y} #{width} #{height}"
    @rescaleTools()

  rescaleTools: ->
    tool.rescale? @getScale() for tool in @tools

  getScale: ->
    scaled = @toScale x: 100, y: 100
    2 / ((scaled.x / 100) + (scaled.y / 100))

  getValue: ->
    JSON.stringify (tool.mark for tool in @tools)

  disable: (e) ->
    @selection?.deselect()
    super

  reset: ->
    # Tools destroy themselves with their marks.
    # Tool controls destroy themselves with their tools.
    @tools[0].destroy() until @tools.length is 0
    null

  destroy: ->
    @reset()
    removeEventListener 'resize', @, false
    super

MarkingSurface.defaultStyle = insertStyle 'marking-surface-default-style', '''
  .marking-surface {
    display: inline-block;
    position: relative;
  }

  .marking-surface-svg {
    display: block;
    -moz-user-select: none;
    -ms-user-select: none;
    -webkit-user-select: none;
  }

  .marking-surface-input {
    left: 0;
    position: absolute;
    opacity: 0;
    pointer-events: none;
    top: 0;
  }

  .marking-surface-tool-focusables-container {
    height: 0;
    left: 0;
    overflow: hidden;
    position: absolute;
    top: 0;
    width: 0;
  }

  .marking-surface-tool-controls-container {
    left: 0;
    position: absolute;
    top: 0;
  }
'''
