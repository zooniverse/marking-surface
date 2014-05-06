{Tool, ToolLabel} = window?.MarkingSurface || require 'marking-surface'

class PointTool extends Tool
  radius: if @mobile then 25 else 15
  strokeWidth: 2

  constructor: ->
    super

    @mark.x = 0
    @mark.y = 0

    @ticks = @addShape 'path',
      stroke: 'currentColor'

    @disc = @addShape 'circle',
      fill: 'transparent'
      stroke: 'currentColor'

    @label = new ToolLabel
      tool: this

    @addEvent 'move', 'circle', @onMove

  rescale: (scale) ->
    super
    scaledRadius = @radius / scale
    scaledStrokeWidth = @strokeWidth / scale

    @ticks.attr
      d: """
        M #{-scaledRadius} 0 L #{-scaledRadius * (1 / 3)} 0 M #{scaledRadius} 0 L #{scaledRadius * (1 / 3)} 0
        M 0 #{-scaledRadius} L 0 #{-scaledRadius * (1 / 3)} M 0 #{scaledRadius} L 0 #{scaledRadius * (1 / 3)}
      """
      strokeWidth: scaledStrokeWidth

    @disc.attr
      r: scaledRadius
      strokeWidth: scaledStrokeWidth

  onInitialStart: (e) ->
    super
    @onInitialMove e

  onInitialMove: (e) ->
    super
    @onMove e

  onMove: (e) ->
    {x, y} = @coords e
    x -= 10
    y -= 10
    @mark.set {x, y}

  render: ->
    super
    @attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls?.moveTo @mark
    @label.setContent "#{@mark.x.toString().split('.')[0]}, #{@mark.y.toString().split('.')[0]}"
    @label.moveTo @mark

window?.MarkingSurface.PointTool = PointTool
module?.exports = PointTool
