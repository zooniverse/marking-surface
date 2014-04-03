MarkingSurface = window.MarkingSurface
{Tool, PointTool, RectangleTool, EllipseTool, AxesTool, TranscriptionTool, MagnifierPointTool, DefaultToolControls} = MarkingSurface

EllipseTool.Controls = DefaultToolControls
AxesTool.Controls = DefaultToolControls

getImage = (src, callback) ->
  img = new Image
  img.onload = ->
    callback? img
  img.src = src

TOOLS =
  point: PointTool
  rectangle: RectangleTool
  ellipse: EllipseTool
  axes: AxesTool
  transcription: TranscriptionTool
  magnifier: MagnifierPointTool

DEMO_IMAGE = './fish.jpg'

ms = new MarkingSurface
  inputName: 'marks'
  tool: TOOLS[$('input[name="tool"]:checked').val()]

getImage DEMO_IMAGE, ({src, width, height}) ->
  ms.image = ms.addShape 'image', 'xlink:href': src, width: width, height: height
  ms.svg.attr width: width * 0.75, height: height * 0.75
  ms.rescale 0, 0, width, height

container = $('#container')
container.append ms.el

marks = $('#marks')
ms.on 'change', ->
  marks.val ms.getValue()

disabledCheckbox = $('#disabled')
disabledCheckbox.on 'change', ->
  checked = !!disabledCheckbox.prop 'checked'
  ms[if checked then 'disable' else 'enable']()

$('input[name="tool"]').on 'change', ({target}) ->
  ms.tool = TOOLS[$(target).val()]

mirror = new MarkingSurface

getImage DEMO_IMAGE, ({width, height}) ->
  mirror.el.style.width = "#{width}px"
  mirror.el.style.height = "#{height}px"
  mirrorImage = mirror.addShape 'image', 'xlink:href': DEMO_IMAGE, width: width, height: height
  mirrorImage.filter 'invert'

mirrorContainer = $('#mirror-container')
mirrorContainer.append mirror.el

ms.on 'add-tool', (tool) ->
  mirroredTool = new tool.constructor
    markingSurface: mirror
    mark: tool.mark
  mirror.addTool mirroredTool

window.ms = ms
window.mirror = mirror
