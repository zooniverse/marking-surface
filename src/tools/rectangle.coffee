{Tool} = window?.MarkingSurface || require 'marking-surface'

class RectangleTool extends Tool
  outside: null
  topLeftHandle: null
  topRightHandle: null
  bottomRightHandle: null
  bottomLeftHandle: null

  handleSize: if !!~navigator.userAgent.indexOf 'iO' then 20 else 10
  fill: 'rgba(128, 128, 128, 0.1)'
  stroke: 'white'
  strokeWidth: 2

  defaultSize: 10

  creationCoords = null
  dragOffsetFromCenter: null

  cursors:
    outside: 'move'

  initialize: ->
    @root.filter 'shadow'
    @outside = @addShape 'rect', {@fill, @stroke, @strokeWidth}
    @topLeftHandle = @addShape 'rect', width: @handleSize, height: @handleSize, fill: @stroke
    @topRightHandle = @addShape 'rect', width: @handleSize, height: @handleSize, fill: @stroke
    @bottomRightHandle = @addShape 'rect', width: @handleSize, height: @handleSize, fill: @stroke
    @bottomLeftHandle = @addShape 'rect', width: @handleSize, height: @handleSize, fill: @stroke

    @mark.set
      left: 0
      top: 0
      width: @defaultSize
      height: @defaultSize

  'on mousedown': (e) ->
    {x, y} = @pointerOffset e
    @dragOffsetFromCenter =
      x: x - @mark.left
      y: y - @mark.top

  'on touchstart': (e) ->
    @['on mousedown'] e

  onFirstClick: (e) ->
    @creationCoords = @pointerOffset e

    @mark.set
      left: @creationCoords.x
      top: @creationCoords.y

    @onFirstDrag e

  onFirstDrag: (e) ->
    {x, y} = @pointerOffset e

    dragMethod = if x < @creationCoords.x and y < @creationCoords.y
      'on drag topLeftHandle'
    else if x >= @creationCoords.x and y < @creationCoords.y
      'on drag topRightHandle'
    else if x >= @creationCoords.x and y >= @creationCoords.y
      'on drag bottomRightHandle'
    else if x < @creationCoords.x and y >= @creationCoords.y
      'on drag bottomLeftHandle'

    @[dragMethod] e

  'on drag topLeftHandle': (e) =>
    {x, y} = @pointerOffset e
    x -= @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      left: x
      top: y
      width: @mark.width + (@mark.left - x)
      height: @mark.height + (@mark.top - y)

  'on drag topRightHandle': (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      top: y
      width: x - @mark.left
      height: @mark.height + (@mark.top - y)

  'on drag bottomRightHandle': (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y += @handleSize / 2

    @mark.set
      width: x - @mark.left
      height: y - @mark.top

  'on drag bottomLeftHandle': (e) =>
    {x, y} = @pointerOffset e
    x -= @handleSize / 2
    y += @handleSize / 2

    @mark.set
      left: x
      width: @mark.width + (@mark.left - x)
      height: y - @mark.top

  'on drag outside': (e) =>
    {x, y} = @pointerOffset e

    @mark.set
      left: x - @dragOffsetFromCenter.x
      top: y - @dragOffsetFromCenter.y

  'on mouseup': =>
    @dragOffsetFromCenter = null

  'on touchend': (e) =>
    @['on mouseup'] e

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

    @controls.moveTo (@mark.left + (@mark.left + @mark.width)) / 2, (@mark.top + (@mark.top + @mark.height)) / 2

window?.MarkingSurface.RectangleTool = RectangleTool
module?.exports = RectangleTool
