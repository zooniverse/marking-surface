class ToolControls extends ElementBase
  className: 'marking-tool-controls'
  template: ''

  constructor: ->
    super

    @el.insertAdjacentHTML 'beforeEnd', @template
    @toFront()

    @addEvent 'mousedown', @onMouseDown

    @tool.on 'select', @onToolSelect
    @tool.on 'deselect', @onToolDeselect
    @tool.on 'destroy', @onToolDestroy
    @tool.mark.on 'change', @onMarkChange

  onMouseDown: =>
    @tool.select()
    null

  onToolSelect: =>
    @toggleClass 'tool-selected', true
    @toFront()
    null

  onToolDeselect: =>
    @toggleClass 'tool-selected', false
    null

  onToolDestroy: =>
    @destroy()
    null

  onMarkChange: =>
    @toggleClass 'tool-complete', @tool.isComplete()
    @render arguments...
    null

  toFront: ->
    @tool.surface.toolControlsContainer.appendChild @el

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

  render: ->
    # Override to reflect the state of the tool's mark.

  destroy: ->
    @el.parentNode.removeChild @el
    super
    null

ToolControls.defaultStyle = insertStyle 'marking-surface-tool-controls-default-style', '''
  .marking-tool-controls {
    opacity: 0.75;
    position: absolute;
  }

  .marking-tool-controls.tool-selected {
    opacity: 1;
  }

  .marking-tool-controls.out-of-bounds {
    display: none
  }
'''
