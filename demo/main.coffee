MarkingSurface = window.MarkingSurface

TOOLS =
  point: MarkingSurface.PointTool
  rectangle: MarkingSurface.RectangleTool
  ellipse: MarkingSurface.EllipseTool
  axes: MarkingSurface.AxesTool
  transcription: MarkingSurface.TranscriptionTool
  magnifier: MarkingSurface.MagnifierPointTool

getImage = (src, callback) ->
  img = new Image
  img.onload = -> callback? img
  img.src = src

DEMO_IMAGE = './fish.jpg'

ms = new MarkingSurface
  inputName: 'marks'
  tool: TOOLS[document.querySelector('input[name="tool"]:checked').value]

getImage DEMO_IMAGE, ({src, width, height}) ->
  ms.image = ms.addShape 'image', 'xlink:href': src, width: width, height: height
  ms.svg.attr width: width * 0.75, height: height * 0.75
  ms.rescale 0, 0, width, height

container = document.getElementById 'container'
container.appendChild ms.el

marks = document.getElementById 'marks'
ms.on 'change', ->
  marks.value = ms.getValue()

disabledCheckbox = document.getElementById 'disabled'
disabledCheckbox.addEventListener 'change', ->
  checked = disabledCheckbox.checked
  ms[if checked then 'disable' else 'enable']()

document.querySelector('input[name="tool"]').addEventListener 'change', ({target}) ->
  ms.tool = TOOLS[target.value]

window.ms = ms
