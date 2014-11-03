class MarkingSurface extends ElementBase
  tag: 'div.marking-surface'
  focusable: true
  inputName: ''

  tool: null # This is the class with which to create new tools.

  selection: null

  scaleX: 1
  scaleY: 1

  constructor: ->
    @tools = []

    super

    @svg = new SVG tag: 'svg.marking-surface-svg'
    @on 'marking-surface:base:destroy', [@svg, 'destroy']

    @svg.addEvent 'marking-surface:mark:change', [@, 'onChangeMark']
    @svg.addEvent 'marking-surface:tool:select', [@, 'onSelectTool']
    @svg.addEvent 'marking-surface:tool:deselect', [@, 'onDeselectTool']
    @svg.addEvent 'marking-surface:tool:destroy', [@, 'onDestroyTool']

    @sizeRect = @svg.addShape 'rect.marking-surface-size-rect',
      fill: 'rgba(0, 0, 0, 0)' # Should be "none", but this fixes a sizing bug in Firefox.
      stroke: 'none'
      strokeWidth: 0
      width: '100%'
      height: '100%'

    @root = @svg.addShape 'g.marking-surface-svg-root'

    @el.appendChild @svg.el

    @toolFocusTargetsContainer = if @focusable
      container = new ElementBase tag: 'div.marking-surface-tool-focusables-container'
      @on 'marking-surface:base:destroy', [container, 'destroy']
      @el.appendChild container.el
      container

    @toolControlsContainer = new ElementBase tag: 'div.marking-surface-tool-controls-container'
    @el.appendChild @toolControlsContainer.el
    @on 'marking-surface:base:destroy', [@toolControlsContainer, 'destroy']

    @input = if @inputName
      input = new ElementBase tag: 'input.marking-surface-input'
      @on 'marking-surface:base:destroy', [input, 'destroy']
      input.el.tabIndex = -1
      input.el.name = @inputName
      @on 'marking-surface:mark:change', [@, 'updateInput']
      @el.appendChild input.el
      input

  addShape: ->
    @root.addShape arguments...

  _onStart: (e) ->
    if matchesSelector e.target, [
      '.marking-surface-tool'
      '.marking-surface-tool *'
      '.marking-surface-tool-controls-container *'
    ].join ','

      return

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

  rescale: (x, y, width, height) ->
    currentViewBox = @svg.attr('viewBox')?.split /\s+/
    x ?= currentViewBox?[0] ? 0
    y ?= currentViewBox?[1] ? 0
    width ?= currentViewBox?[2] ? 0
    height ?= currentViewBox?[3] ? 0
    @svg.attr 'viewBox', [x, y, width, height].join ' '
    scaled = @screenPixelToScale x: 100, y: 100
    @scaleX = 100 / scaled.x
    @scaleY = 100 / scaled.y

    unless @scaleX is 0 or @scaleY is 0
      @renderTools()

  addTool: (tool) ->
    tool ?= new @tool
    tool.markingSurface = this
    @tools.push tool

    @root.el.appendChild tool.el
    tool.trigger 'marking-surface:tool:added', [this]

    tool.render()

    @trigger 'marking-surface:add-tool', [tool]
    @trigger 'marking-surface:change'

    tool

  onSelectTool: (e) ->
    [tool] = e.detail
    unless @selection is tool
      @selection?.deselect()
      @selection = tool
      @trigger 'marking-surface:select-tool', [@selection]

  onChangeMark: (e) ->
    [mark] = e.detail
    @trigger 'marking-surface:change', [mark]

  updateInput: ->
    @input.el.value = @getValue()

  onDeselectTool: (e) ->
    [tool] = e.detail
    if @selection is tool
      @selection = null
      @trigger 'marking-surface:deselect-tool', [tool]

  onDestroyTool: (e) ->
    [tool] = e.detail
    index = @tools.indexOf tool
    @tools.splice index, 1
    @trigger 'marking-surface:remove-tool', [tool]
    @trigger 'marking-surface:change'

  screenPixelToScale: ({x, y}) ->
    if @svg.el.viewBox.animVal?
      viewBox = @svg.el.viewBox.animVal
      sizeRect = @sizeRect.el.getBoundingClientRect()
      x += viewBox.x
      x *= viewBox.width / sizeRect.width
      y += viewBox.y
      y *= viewBox.height / sizeRect.height
    {x, y}

  scalePixelToScreen: ({x, y}) ->
    if @svg.el.viewBox.animVal?
      viewBox = @svg.el.viewBox.animVal
      sizeRect = @sizeRect.el.getBoundingClientRect()
      x /= viewBox.width / sizeRect.width
      x -= viewBox.x
      y /= viewBox.height / sizeRect.height
      y -= viewBox.y
    {x, y}

  renderTools: ->
    for tool in @tools
      tool.render()

  getValue: ->
    JSON.stringify (tool.mark for tool in @tools)

  disable: (e) ->
    @selection?.deselect()
    super

  reset: ->
    until @tools.length is 0
      @tools[0].destroy()
    @trigger 'marking-surface:reset'

  destroy: ->
    @reset()
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
