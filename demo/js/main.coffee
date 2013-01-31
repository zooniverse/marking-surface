Raphael = window.Raphael
MarkingSurface = window.MarkingSurface
{Tool} = MarkingSurface

class PointTool extends Tool
  circle: null
  markDefaults: type: 'point'

  cursors: circle: 'move'

  constructor: ->
    super
    @hr = @addShape 'rect', -20, -1, 40, 2, fill: 'green', 'stroke-width': 0
    @vr = @addShape 'rect', -1, -20, 2, 40, fill: 'blue', 'stroke-width': 0
    @circle = @addShape 'circle', 0, 0, 10, fill: 'red', 'stroke-width': 0

  onInitialClick: (e) ->
    super
    @['on drag circle'] e

  onInitialDrag: (e) ->
    super
    @['on drag circle'] e

  'on drag circle': (e) ->
    offset = @surface.mouseOffset e
    @mark.set @surface.mouseOffset e

  render: ->
    super
    @circle.attr r: 10 / @surface.zoomBy
    @shapeSet.transform "t #{@mark.x} #{@mark.y}"

  select: ->
    super
    @circle.attr 'stroke-width', 3

  deselect: ->
    super
    @circle.attr 'stroke-width', 0

demoImage = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'
ms = new MarkingSurface tool: PointTool, background: demoImage

disabledCheckbox = $('#disabled')
disabledCheckbox.on 'change': ->
  checked = !!disabledCheckbox.attr 'checked'
  ms[if checked then 'disable' else 'enable']()

zoomSlider = $('#zoom')
zoomSlider.on 'change', ->
  ms.zoom zoomSlider.val()

noZoomButton = $('#no-zoom')
noZoomButton.on 'click', ->
  zoomSlider.val 1
  ms.zoom 1

ms.container.appendTo 'body'

window.ms = ms
