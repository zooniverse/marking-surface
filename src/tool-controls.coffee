class ToolControls extends ElementBase
  tool: null

  className: 'marking-tool-controls'

  isOpen: false

  constructor: ->
    super

    @el.innerHTML = @template

    @addEvent 'mousedown', @onMouseDown

    @tool.on 'initial-release', @onToolInitialRelease
    @tool.on 'select', @onToolSelect
    @tool.mark.on 'change', @onMarkChange
    @tool.on 'deselect', @onToolDeselect
    @tool.on 'destroy', @onToolDestroy

    @tool.surface.el.appendChild @el

  onToolInitialRelease: =>
    @toggleClass 'tool-complete', @tool.isComplete()
    null

  onMouseDown: =>
    return if @tool.surface.disabled
    @tool.select()
    null

  onToolSelect: =>
    @toggleClass 'tool-selected', true
    @el.parentNode.appendChild @el
    @open() unless @isOpen
    @isOpen = true
    null

  onMarkChange: =>
    @render arguments...
    null

  onToolDeselect: =>
    @toggleClass 'tool-selected', false
    @close() if @isOpen
    @isOpen = false
    null

  onToolDestroy: =>
    @destroy()
    null

  destroy: ->
    @el.parentNode.removeChild @el
    super
    null

  moveTo: (x, y) ->
    {zoomBy, panX, panY} = @tool.surface
    width = @tool.surface.el.clientWidth
    height = @tool.surface.el.clientHeight

    panX *= width - (width / zoomBy)
    panY *= height - (height / zoomBy)

    left = Math.floor (x * zoomBy) - (panX * zoomBy)
    top = Math.floor (y * zoomBy) - (panY * zoomBy)

    @el.style.left    = "#{left}px"
    @el.style.top     = "#{top}px"

    opensRight = x < width / 2
    opensDown = y < height / 2

    @toggleClass 'opens-right', opensRight
    @toggleClass 'opens-left', not opensRight
    @toggleClass 'opens-down', opensDown
    @toggleClass 'opens-up', not opensDown

    outOfBounds = left < 0 or left > width or top < 0 or top > height

    @toggleClass 'out-of-bounds', outOfBounds

    null

  open: ->
    # When the tool is selected

  close: ->
    # When the tool is deselected

  render: ->
    # Reflect the state of the tool's mark.

ToolControls.defaultStyle = insertStyle 'marking-surface-tool-controls-default-style', '''
  .marking-tool-controls {
    position: absolute;
  }

  .marking-tool-controls.out-of-bounds {
    display: none
  }
'''
