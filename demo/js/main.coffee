MarkingSurface = window.MarkingSurface
{Tool, EllipseTool, AxesTool} = MarkingSurface

class PointTool extends Tool
  hr: null
  vr: null
  circle: null

  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  color: [255, 0, 255]

  cursors:
    circle: 'move'

  initialize: ->
    @hr = @addShape 'line', x1: 0, y1: -@size, x2: 0, y2: @size, stroke: "rgb(#{@color})", strokeWidth: 2
    @vr = @addShape 'line', x1: -@size, y1: 0, x2: @size, y2: 0, stroke: "rgb(#{@color})", strokeWidth: 2
    @circle = @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'rgba(255, 255, 255, 0.25)', stroke: "rgb(#{@color})", strokeWidth: 2

  onInitialClick: (e) ->
    @onInitialDrag e

  onInitialDrag: (e) ->
    @['on drag circle'] e

  'on drag circle': (e) =>
    offset = @pointerOffset e
    @mark.set offset

  render: ->
    @circle.attr
      r: @size / 2 / @surface.zoomBy
      strokeWidth: 2 / @surface.zoomBy

    @hr.attr strokeWidth: 2 / @surface.zoomBy
    @vr.attr strokeWidth: 2 / @surface.zoomBy

    @group.attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls.moveTo @mark.x, @mark.y

# DEMO_IMAGE = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'

TOOLS =
  point: PointTool
  ellipse: EllipseTool
  axes: AxesTool

ms = new MarkingSurface
  tool: TOOLS[$('input[name="tool"]:checked').val()]
  width: 640
  height: 480

disabledCheckbox = $('#disabled')
disabledCheckbox.on 'change', ->
  checked = !!disabledCheckbox.prop 'checked'
  ms[if checked then 'disable' else 'enable']()

zoomSlider = $('#zoom')
zoomSlider.on 'change', ->
  ms.zoom zoomSlider.val()

noZoomButton = $('#no-zoom')
noZoomButton.on 'click', ->
  zoomSlider.val 1
  ms.zoom 1

$('input[name="tool"]').on 'change', ({target}) ->
  ms.tool = TOOLS[$(target).val()]

document.body.appendChild ms.el
window.ms = ms
