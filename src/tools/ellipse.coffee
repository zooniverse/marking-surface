{Tool} = window?.MarkingSurface || require 'marking-surface'

class EllipseTool extends Tool
  path: null
  outside: null
  xHandle: null
  yHandle: null

  handleRadius: if !!~navigator.userAgent.indexOf 'iO' then 20 else 10
  fill: 'rgba(128, 128, 128, 0.1)'
  stroke: 'white'
  strokeWidth: 2

  defaultRadius: 2
  defaultSquash: 0.5

  dragOffsetFromCenter: null

  cursors:
    outside: '*grab'
    xHandle: 'move'
    yHandle: 'move'

  initialize: ->
    @root.filter 'shadow'
    @path = @addShape 'path', {d: 'M 0 0', @stroke, @strokeWidth, strokeDasharray: [@strokeWidth * 4, @strokeWidth * 4]}
    @outside = @addShape 'ellipse', {@fill, @stroke, @strokeWidth}
    @xHandle = @addShape 'circle', {r: @handleRadius, @fill, @stroke, @strokeWidth}
    @yHandle = @addShape 'circle', {r: @handleRadius, @fill, @stroke, @strokeWidth}

    @mark.set
      center: [0, 0]
      angle: 0
      rx: 0
      ry: 0

  onFirstClick: (e) ->
    {x, y} = @pointerOffset e

    @mark.set
      center: [x, y]
      rx: @defaultRadius
      ry: @defaultRadius * @defaultSquash

  onFirstDrag: (e) ->
    @['on *drag xHandle'] e
    @mark.set 'ry', @mark.rx * @defaultSquash

  'on *start': (e) ->
    {x, y} = @pointerOffset e
    @dragOffsetFromCenter =
      x: x - @mark.center[0]
      y: y - @mark.center[1]

  'on *drag outside': (e) =>
    {x, y} = @pointerOffset e
    @mark.set 'center', [
      x - @dragOffsetFromCenter.x
      y - @dragOffsetFromCenter.y
    ]

  'on *drag xHandle': (e) =>
    {x, y} = @pointerOffset e
    @mark.set
      angle: @getAngle @mark.center[0], @mark.center[1], x, y
      rx: @getHypotenuse @mark.center[0], @mark.center[1], x, y

  'on *drag yHandle': (e) =>
    {x, y} = @pointerOffset e
    @mark.set
      angle: 90 + @getAngle @mark.center[0], @mark.center[1], x, y
      ry: @getHypotenuse @mark.center[0], @mark.center[1], x, y

  'on *end': =>
    @dragOffsetFromCenter = null

  render: ->
    @group.attr 'transform', "translate(#{@mark.center}) rotate(#{@mark.angle})"
    @path.attr 'd', "M 0 #{-@mark.ry} L 0 0 M #{@mark.rx} 0 L 0 0"
    @outside.attr rx: @mark.rx, ry: @mark.ry
    @xHandle.attr 'cx', @mark.rx
    @yHandle.attr 'cy', -@mark.ry
    @controls.moveTo @mark.center...

  getAngle: (x1, y1, x2, y2) ->
    deltaX = x2 - x1
    deltaY = y2 - y1
    Math.atan2(deltaY, deltaX) * (180 / Math.PI)

  getHypotenuse: (x1, y1, x2, y2) ->
    aSquared = Math.pow x2 - x1, 2
    bSquared = Math.pow y2 - y1, 2
    Math.sqrt aSquared + bSquared

window?.MarkingSurface.EllipseTool = EllipseTool
module?.exports = EllipseTool
