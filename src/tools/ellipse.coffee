{Tool} = window?.MarkingSurface || require 'marking-surface'

class EllipseTool extends Tool
  outside: null
  center: null
  xHandle: null
  yHandle: null

  handleRadius: if !!~navigator.userAgent.indexOf 'iO' then 20 else 10
  stroke: 'black'
  strokeWidth: 2
  handleFill: 'rgba(128, 128, 128, 0.1)'

  defaultRadius: @::handleRadius * 2
  defaultSquash: 0.5

  cursors:
    center: 'move'
    xHandle: 'move'
    yHandle: 'move'

  initialize: ->
    @outside = @addShape 'ellipse', fill: 'transparent', stroke: @stroke, strokeWidth: @strokeWidth
    @center = @addShape 'circle', r: @handleRadius, fill: @handleFill, stroke: @stroke, strokeWidth: @strokeWidth
    @xHandle = @addShape 'circle', r: @handleRadius, fill: @handleFill, stroke: @stroke, strokeWidth: @strokeWidth
    @yHandle = @addShape 'circle', r: @handleRadius, fill: @handleFill, stroke: @stroke, strokeWidth: @strokeWidth

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
    @['on drag xHandle'] e
    @mark.set 'ry', @mark.rx * @defaultSquash

  'on drag center': (e) =>
    {x, y} = @pointerOffset e
    @mark.set 'center', [x, y]

  'on drag xHandle': (e) =>
    {x, y} = @pointerOffset e
    @mark.set
      angle: @getAngle @mark.center[0], @mark.center[1], x, y
      rx: @getHypotenuse @mark.center[0], @mark.center[1], x, y

  'on drag yHandle': (e) =>
    {x, y} = @pointerOffset e
    @mark.set
      angle: 90 + @getAngle @mark.center[0], @mark.center[1], x, y
      ry: @getHypotenuse @mark.center[0], @mark.center[1], x, y

  render: ->
    @group.attr 'transform', "translate(#{@mark.center}) rotate(#{@mark.angle})"
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
