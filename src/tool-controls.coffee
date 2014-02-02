class ToolControls extends ElementBase
  tag: 'div.marking-surface-tool-controls'
  template: ''

  constructor: ->
    super
    @el.insertAdjacentHTML 'beforeEnd', @template

    @tool.on 'select', [@, 'onToolSelect']
    @tool.mark.on 'change', [@, 'onMarkChange']
    @tool.on 'deselect', [@, 'onToolDeselect']
    @tool.on 'destroy', [@, 'onToolDestroy']

  onToolSelect: ->
    @toFront()
    @attr 'data-selected', true

  onToolDeselect: ->
    @attr 'data-selected', null

  onToolDestroy: ->
    @destroy()

  onMarkChange: ->
    @render? arguments...

  moveTo: ({x, y}) ->
    {x, y} = @tool.markingSurface.toPixels {x, y}
    width = @tool.markingSurface.el.offsetWidth
    height = @tool.markingSurface.el.offsetHeight
    outOfBounds = x < 0 or x > width or y < 0 or y > height
    @attr 'data-out-of-bounds', outOfBounds || null
    @el.style.left = "#{x}px"
    @el.style.top = "#{y}px"
    @attr 'data-horizontal-room', if x < width / 2 then 'right' else 'left'
    @attr 'data-vertical-room', if y < height / 2 then 'down' else 'up'

  render: ->
    @attr 'data-complete', @tool.isComplete() || null

ToolControls.defaultStyle = insertStyle 'marking-surface-tool-controls-default-style', '''
  .marking-surface-tool-controls {
    position: absolute;
  }

  .marking-surface-tool-controls:not([data-selected]) {
    display: none;
  }

  .marking-surface-tool-controls[data-out-of-bounds] {
    display: none;
  }
'''
