MarkingSurface = require '/src/marking-surface'
{Mark, Tool} = MarkingSurface
Raphael = window.Raphael


class PointTool extends Tool
  circle: null
  markDefaults: type: 'point'

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
    @mark.set @surface.mouseOffset e

  render: ->
    @shapeSet.transform "t #{@mark.x} #{@mark.y}"

  select: ->
    super
    @circle.attr 'stroke-width', 3

  deselect: ->
    super
    @circle.attr 'stroke-width', 0

demoImage = 'http://www.seafloorexplorer.org/images/field-guide/fish.jpg'
window.ms = new MarkingSurface tool: PointTool, image: demoImage
window.ms.container.appendTo 'body'
