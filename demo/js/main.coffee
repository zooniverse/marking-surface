MarkingSurface = require '/src/marking-surface'
{Mark, Tool} = MarkingSurface
Raphael = window.Raphael


class PointTool extends Tool
  circle: null
  markDefaults: type: 'point'

  constructor: ->
    super
    @circle = @addShape 'circle', 0, 0, 10
    @circle.attr fill: 'red'

  onInitialClick: (e) ->
    super
    @['on drag circle'] e

  onInitialDrag: (e) ->
    super
    @['on drag circle'] e

  'on drag circle': (e) ->
    @mark.set @surface.mouseOffset e

  render: ->
    @shapeSet.transform {}
    @shapeSet.translate @mark.x, @mark.y

  select: ->
    super
    @circle.attr 'stroke-width', 3

  deselect: ->
    super
    @circle.attr 'stroke-width', 1


window.ms = new MarkingSurface tool: PointTool
window.ms.container.appendTo 'body'
