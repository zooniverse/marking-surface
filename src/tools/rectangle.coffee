{Tool} = window?.MarkingSurface || require 'marking-surface'

class RectangleTool extends Tool
  handleSize: if @mobile then 14 else 7
  strokeWidth: 2

  startOffset = null
  pointerOffsetFromShape: null

  constructor: ->
    super

    @mark.left = 0
    @mark.top = 0
    @mark.width = 0
    @mark.height = 0

    @outline = @addShape 'rect.outline', fill: 'transparent', stroke: 'currentColor'

    @addEvent 'start', '.outline', @startDrag
    @addEvent 'move', '.outline', @moveOutline

    handleDefaults =
      r: @handleSize
      fill: 'currentColor'
      stroke: 'transparent'

    @topLeftHandle = @addShape 'circle.top-left.handle', handleDefaults
    @topRightHandle = @addShape 'circle.top-right.handle', handleDefaults
    @bottomRightHandle = @addShape 'circle.bottom-right.handle', handleDefaults
    @bottomLeftHandle = @addShape 'circle.bottom-left.handle', handleDefaults

    @addEvent 'start', '.top-left.handle', @startTopLeftHandle
    @addEvent 'start', '.top-right.handle', @startTopRightHandle
    @addEvent 'start', '.bottom-right.handle', @startBottomRightHandle
    @addEvent 'start', '.bottom-left.handle', @startBottomLeftHandle
    @addEvent 'move', '.handle', @moveAnyHandle

    @handles = [@topLeftHandle, @topRightHandle, @bottomRightHandle, @bottomLeftHandle]

  onInitialStart: (e) ->
    super
    @startDrag e
    @mark.set
      left: @startOffset.x
      top: @startOffset.y

  onInitialMove: (e) ->
    super
    @moveAnyHandle e

  startDrag: (e) ->
    @startOffset = @coords e
    @shapeOffset =
      x: @startOffset.x - @mark.left
      y: @startOffset.y - @mark.top

  moveOutline: (e) ->
    {x, y} = @coords e
    @mark.set
      left: x - @shapeOffset.x
      top: y - @shapeOffset.y

  startTopLeftHandle: (e) ->
    @startOffset =
      x: @mark.left + @mark.width
      y: @mark.top + @mark.height

  startTopRightHandle: (e) ->
    @startOffset =
      x: @mark.left
      y: @mark.top + @mark.height

  startBottomRightHandle: (e) ->
    @startOffset =
      x: @mark.left
      y: @mark.top

  startBottomLeftHandle: (e) ->
    @startOffset =
      x: @mark.left + @mark.width
      y: @mark.top

  moveAnyHandle: (e) ->
    {x, y} = @coords e

    dragMethod = if x < @startOffset.x and y < @startOffset.y
      'dragFromTopLeft'
    else if x >= @startOffset.x and y < @startOffset.y
      'dragFromTopRight'
    else if x >= @startOffset.x and y >= @startOffset.y
      'dragFromBottomRight'
    else if x < @startOffset.x and y >= @startOffset.y
      'dragFromBottomLeft'

    @[dragMethod] e

  dragFromTopLeft: (e) =>
    {x, y} = @coords e
    x -= @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      left: x
      top: y
      width: @mark.width + (@mark.left - x)
      height: @mark.height + (@mark.top - y)

  dragFromTopRight: (e) =>
    {x, y} = @coords e
    x += @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      top: y
      width: x - @mark.left
      height: @mark.height + (@mark.top - y)

  dragFromBottomRight: (e) =>
    {x, y} = @coords e
    x += @handleSize / 2
    y += @handleSize / 2

    @mark.set
      width: x - @mark.left
      height: y - @mark.top

  dragFromBottomLeft: (e) =>
    {x, y} = @coords e
    x -= @handleSize / 2
    y += @handleSize / 2

    @mark.set
      left: x
      width: @mark.width + (@mark.left - x)
      height: y - @mark.top

  render: ->
    super

    scale = (@markingSurface?.scaleX + @markingSurface?.scaleY) / 2
    strokeWidth = @strokeWidth / scale
    handleSize = @handleSize / scale

    @outline.attr 'strokeWidth', strokeWidth

    for handle in @handles
      handle.attr
        r: handleSize
        strokeWidth: strokeWidth

    @outline.attr
      x: @mark.left
      y: @mark.top
      width: @mark.width
      height: @mark.height

    @topLeftHandle.attr cx: @mark.left, cy: @mark.top
    @topRightHandle.attr cx: @mark.left + @mark.width, cy: @mark.top
    @bottomRightHandle.attr cx: @mark.left + @mark.width, cy: @mark.top + @mark.height
    @bottomLeftHandle.attr cx: @mark.left, cy: @mark.top + @mark.height

    @controls?.moveTo [@mark.left + @mark.width, @mark.top]

window?.MarkingSurface.RectangleTool = RectangleTool
module?.exports = RectangleTool
