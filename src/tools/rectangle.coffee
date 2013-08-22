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

  creationCoords = null
  dragOffsetFromCenter: null

  cursors:
    outside: 'move'

  initialize: ->
    @root.filter 'shadow'

    @outside = @addShape 'rect', {@fill, @stroke, @strokeWidth}

    @topLeftHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @topRightHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @bottomRightHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}
    @bottomLeftHandle = @addShape 'rect', {width: @handleSize, height: @handleSize, @fill, @stroke, @strokeWidth}

    @handles = []
    @handles.push @topLeftHandle, @topRightHandle, @bottomRightHandle, @bottomLeftHandle

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
    @['on drag handles'] e

  'on drag handles': (e) =>
    {x, y} = @pointerOffset e

    dragMethod = if x < @creationCoords.x and y < @creationCoords.y
      'onDragTopLeftHandle'
    else if x >= @creationCoords.x and y < @creationCoords.y
      'onDragTopRightHandle'
    else if x >= @creationCoords.x and y >= @creationCoords.y
      'onDragBottomRightHandle'
    else if x < @creationCoords.x and y >= @creationCoords.y
      'onDragBottomLeftHandle'

    @[dragMethod] e

  onDragTopLeftHandle: (e) =>
    {x, y} = @pointerOffset e
    x -= @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      left: x
      top: y
      width: @mark.width + (@mark.left - x)
      height: @mark.height + (@mark.top - y)

  onDragTopRightHandle: (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y -= @handleSize / 2

    @mark.set
      top: y
      width: x - @mark.left
      height: @mark.height + (@mark.top - y)

  onDragBottomRightHandle: (e) =>
    {x, y} = @pointerOffset e
    x += @handleSize / 2
    y += @handleSize / 2

    @mark.set
      width: x - @mark.left
      height: y - @mark.top

  onDragBottomLeftHandle: (e) =>
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

    @positionControls()

  positionControls: ->
    @controls.moveTo @mark.left + @mark.width, @mark.top, true

window?.MarkingSurface.RectangleTool = RectangleTool
module?.exports = RectangleTool
