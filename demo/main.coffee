MarkingSurface = window.MarkingSurface
{Tool, RectangleTool, EllipseTool, AxesTool, TranscriptionTool, MagnifierPointTool, DefaultToolControls} = MarkingSurface

RectangleTool.Controls = DefaultToolControls
EllipseTool.Controls = DefaultToolControls
AxesTool.Controls = DefaultToolControls

getImageSize = (src, callback) ->
  img = new Image
  img.src = src
  img.onload = ->
    callback img.width, img.height

class PointTool extends Tool
  @Controls: DefaultToolControls

  hr: null
  vr: null
  circle: null

  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  stroke: 'white'

  cursors:
    circle: 'move'

  initialize: ->
    @addShape 'path', d: """
      M #{-@size} 0 L #{-@size * (1 / 3)} 0 M #{@size} 0 L #{@size * (1 / 3)} 0
      M 0 #{-@size} L 0 #{-@size * (1 / 3)} M 0 #{@size} L 0 #{@size * (1 / 3)}
    """, stroke: @stroke, strokeWidth: 2
    @circle = @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'transparent', stroke: @stroke, strokeWidth: 2

  onInitialClick: (e) ->
    @onInitialDrag e

  onInitialDrag: (e) ->
    @['on *drag circle'] e

  'on *drag circle': (e) =>
    offset = @pointerOffset e
    @mark.set offset

  render: ->
    @group.attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls.moveTo @mark.x, @mark.y

TOOLS =
  point: PointTool
  rectangle: RectangleTool
  ellipse: EllipseTool
  axes: AxesTool
  transcription: TranscriptionTool
  magnifier: MagnifierPointTool

DEMO_IMAGE = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'

ms = new MarkingSurface
  tool: TOOLS[$('input[name="tool"]:checked').val()]
  width: 640
  height: 480

getImageSize DEMO_IMAGE, (width, height) ->
  ms.el.style.width = "#{width}px"
  ms.el.style.height = "#{height}px"
  ms.addShape 'image', 'xlink:href': DEMO_IMAGE, width: width, height: height

container = $('#container')
container.append ms.el

marks = $('#marks')
ms.on 'change', ->
  marks.val ms.getValue()

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

mirror = new MarkingSurface
  width: 640
  height: 480

getImageSize DEMO_IMAGE, (width, height) ->
  mirror.el.style.width = "#{width}px"
  mirror.el.style.height = "#{height}px"
  mirrorImage = mirror.addShape 'image', 'xlink:href': DEMO_IMAGE, width: width, height: height
  mirrorImage.filter 'invert'

mirrorContainer = $('#mirror-container')
mirrorContainer.append mirror.el

ms.on 'create-mark', (mark) ->
  mirroredTool = new ms.tool
    surface: mirror
    mark: mark
  mirror.addTool mirroredTool

window.ms = ms
window.mirror = mirror
