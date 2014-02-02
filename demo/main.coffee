MarkingSurface = window.MarkingSurface
{Tool, RectangleTool, EllipseTool, AxesTool, TranscriptionTool, MagnifierPointTool, DefaultToolControls} = MarkingSurface

getImage = (src, callback) ->
  img = new Image
  img.onload = ->
    callback? img
  img.src = src

class PointTool extends Tool
  @Controls: DefaultToolControls
  size: if !!~navigator.userAgent.indexOf 'iO' then 40 else 20
  strokeWidth: 2

  constructor: ->
    super

    @size = @scale @size
    @strokeWidth = @scale @strokeWidth

    @mark.x = 0
    @mark.y = 0

    @addShape 'path', d: """
      M #{-@size} 0 L #{-@size * (1 / 3)} 0 M #{@size} 0 L #{@size * (1 / 3)} 0
      M 0 #{-@size} L 0 #{-@size * (1 / 3)} M 0 #{@size} L 0 #{@size * (1 / 3)}
    """, stroke: 'currentColor', strokeWidth: @strokeWidth

    @addShape 'circle', cx: 0, cy: 0, r: @size, fill: 'transparent', stroke: 'currentColor', strokeWidth: @strokeWidth

    @addEvent 'move', 'circle', @onMove

  onInitialStart: (e) ->
    super
    @onInitialMove e

  onInitialMove: (e) ->
    super
    @onMove e

  onMove: (e) ->
    {x, y} = @coords e
    x -= 10
    y -= 10
    @mark.set {x, y}

  render: ->
    @attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls.moveTo @mark

TOOLS =
  point: PointTool
  rectangle: RectangleTool
  ellipse: EllipseTool
  axes: AxesTool
  transcription: TranscriptionTool
  magnifier: MagnifierPointTool

DEMO_IMAGE = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'

ms = new MarkingSurface
  name: 'marking-surface'
  tool: TOOLS[$('input[name="tool"]:checked').val()]

getImage DEMO_IMAGE, ({src, width, height}) ->
  ms.svg.attr width: width * 0.75, height: height * 0.75, viewBox: "0 0 #{width} #{height}"
  ms.image = ms.addShape 'image', 'xlink:href': src, width: '100%', height: '100%'

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
# window.mirror = mirror
