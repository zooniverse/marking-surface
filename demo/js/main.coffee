MarkingSurface = window.MarkingSurface
{Tool, AxesTool} = MarkingSurface

class PointTool extends Tool
  cursors:
    circle: 'move'

  markDefaults:
    type: 'POINT'
    _label: 'Point'

  initialize: ->
    @hr = @addShape 'line', x1: 0, y1: -20, x2: 0, y2: 20, stroke: 'red', strokeWidth: 2
    @vr = @addShape 'line', x1: -20, y1: 0, x2: 20, y2: 0, stroke: 'red', strokeWidth: 2
    @circle = @addShape 'circle', cx: 0, cy: 0, r: 10, fill: 'rgba(255, 0, 0, 0.25)', stroke: 'red', strokeWidth: 2

  onInitialClick: (e) ->
    @['on drag circle'] e

  onInitialDrag: (e) ->
    @['on drag circle'] e

  'on drag circle': (e) =>
    offset = @surface.pointerOffset e
    @mark.set offset

  render: ->
    @circle.attr r: 10 / @surface.zoomBy, strokeWidth: 2 / @surface.zoomBy
    @hr.attr strokeWidth: 2 / @surface.zoomBy
    @vr.attr strokeWidth: 2 / @surface.zoomBy
    @group.attr 'transform', "translate(#{@mark.get 'x', 'y'})"
    @controls.moveTo (@mark.get 'x', 'y')...

# demoImage = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'

ms = new MarkingSurface
  tool: PointTool
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

tools = axes: AxesTool, point: PointTool
$('button[name="tool"]').on 'click', ({target}) ->
  ms.tool = tools[$(target).val()]

document.body.appendChild ms.container

window.ms = ms
