class ToolControls extends ElementBase
  tag: 'div.marking-surface-tool-controls'
  template: ''

  constructor: ->
    super

    @el.insertAdjacentHTML 'beforeEnd', @template

    @tool.on 'marking-surface:tool:added', [@, 'followTool']
    @tool.addEvent 'marking-surface:tool:select', [@, 'toFront']
    @tool.addEvent 'marking-surface:tool:select', [@, 'attr', 'data-selected', true]
    @tool.addEvent 'marking-surface:tool:deselect', [@, 'attr', 'data-selected', null]
    @tool.on 'marking-surface:element:remove', [@, 'remove']
    @tool.addEvent 'marking-surface:tool:destroy', [@, 'destroy']

    @tool.mark.on 'marking-surface:mark:change', [@, 'render']

  followTool: ->
    @tool.markingSurface.toolControlsContainer.el.appendChild @el

  moveTo: ({x, y}) ->
    {x, y} = @tool.markingSurface.scalePixelToScreen {x, y}
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
