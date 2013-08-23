{Tool} = window?.MarkingSurface || require 'marking-surface'

class RectangleTool extends Tool
  outside: null
  handles: null
  topLeftHandle: null
  topRightHandle: null
  bottomRightHandle: null
  bottomLeftHandle: null

  handleSize: if !!~navigator.userAgent.indexOf 'iO' then 20 else 10
  fill: 'rgba(128, 128, 128, 0.1)'
  stroke: 'white'
  strokeWidth: 2

  defaultSize: 10

  startCoords = null
  pointerOffsetFromShape: null

  cursors:
    outside: '*grab'
    handles: 'move'

  initialize: ->
    @root.filter 'shadow'

    @outside = @addShape 'rect', {@fill, @stroke, @strokeWidth}

    @topLeftHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @topRightHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @bottomRightHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @bottomLeftHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}

    @handles = [@topLeftHandle, @topRightHandle, @bottomRightHandle, @bottomLeftHandle]

    @mark.set
      left: 0
      top: 0
      width: @defaultSize
      height: @defaultSize

  'on *start outside': (e) ->
    @startCoords = @pointerOffset e
    @pointerOffsetFromShape =
      x: @startCoords.x - @mark.left
      y: @startCoords.y - @mark.top

  'on *drag outside': (e) ->
    {x, y} = @pointerOffset e
    @mark.set
      left: x - @pointerOffsetFromShape.x
      top: y - @pointerOffsetFromShape.y

  onFirstClick: (e) ->
    @startCoords = @pointerOffset e

    @mark.set
      left: @startCoords.x - (@defaultSize / 2)
      top: @startCoords.y - (@defaultSize / 2)

  onFirstDrag: (e) ->
    @['on *drag handles'] e

  'on *start topLeftHandle': (e) ->
    @startCoords =
      x: @mark.left + @mark.width
      y: @mark.top + @mark.height

  'on *start topRightHandle': (e) ->
    @startCoords =
      x: @mark.left
      y: @mark.top + @mark.height

  'on *start bottomRightHandle': (e) ->
    @startCoords =
      x: @mark.left
      y: @mark.top

  'on *start bottomLeftHandle': (e) ->
    @startCoords =
      x: @mark.left + @mark.width
      y: @mark.top

  'on *drag handles': (e) ->
    {x, y} = @pointerOffset e

    dragMethod = if x < @startCoords.x and y < @startCoords.y
      'dragFromTopLeft'
    else if x >= @startCoords.x and y < @startCoords.y
      'dragFromTopRight'
    else if x >= @startCoords.x and y >= @startCoords.y
      'dragFromBottomRight'
    else if x < @startCoords.x and y >= @startCoords.y
      'dragFromBottomLeft'

    @[dragMethod] e

  dragFromTopLeft: (e) =>
    {x, y} = @pointerOffset e
    x -= @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      left: x
      top: y
      width: @mark.width + (@mark.left - x)
      height: @mark.height + (@mark.top - y)

  dragFromTopRight: (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      top: y
      width: x - @mark.left
      height: @mark.height + (@mark.top - y)

  dragFromBottomRight: (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y += @handleSize / 2

    @mark.set
      width: x - @mark.left
      height: y - @mark.top

  dragFromBottomLeft: (e) =>
    {x, y} = @pointerOffset e
    x -= @handleSize / 2
    y += @handleSize / 2

    @mark.set
      left: x
      width: @mark.width + (@mark.left - x)
      height: y - @mark.top

  render: ->
    @outside.attr
      x: @mark.left
      y: @mark.top
      width: @mark.width
      height: @mark.height

    @topLeftHandle.attr x: @mark.left, y: @mark.top
    @topRightHandle.attr x: @mark.left + (@mark.width - @handleSize), y: @mark.top
    @bottomRightHandle.attr x: @mark.left + (@mark.width - @handleSize), y: @mark.top + (@mark.height - @handleSize)
    @bottomLeftHandle.attr x: @mark.left, y: @mark.top + (@mark.height - @handleSize)

    @positionControls()

  positionControls: ->
    @controls.moveTo @mark.left + @mark.width, @mark.top, true

window?.MarkingSurface.RectangleTool = RectangleTool
module?.exports = RectangleTool
