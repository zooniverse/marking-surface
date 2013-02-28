{Tool} = window.MarkingSurface
$ = window.jQuery
Raphael = window.Raphael

dotRadius = if 'Touch' of window then 20 else 5

class AxesTool extends Tool
  cross: null
  dots: null

  markDefaults:
    p0: [-20, -20], p1: [-20, -20]
    p2: [-20, -20], p3: [-20, -20]

  cursors:
    'dots': 'move'

  initialize: ->
    @cross = @addShape 'path', 'M 0 0', stroke: 'red', 'stroke-width': 3

    dotShapes = for i in [0...4]
      @addShape 'circle', 0, 0, dotRadius, fill: 'black', stroke: 'red', 'stroke-width': 3

    @dots = @surface.paper.set dotShapes

  onFirstClick: (e) ->
    {x, y} = @mouseOffset e
    points = if @clicks is 0 then ['p0', 'p1', 'p2', 'p3'] else ['p2', 'p3']
    @mark.set point, [x, y] for point in points

  onFirstDrag: (e) ->
    {x, y} = @mouseOffset e
    points = if @clicks is 0 then ['p1', 'p3'] else ['p3']
    @mark.set point, [x, y] for point in points

  isComplete: ->
    @clicks is 2

  'on drag dots': (e, shape) ->
    index = $.inArray shape, @dots
    {x, y} = @mouseOffset e
    @mark.set "p#{index}", [x, y]

  render: ->
    for point, i in ['p0', 'p1', 'p2', 'p3']
      @dots[i].attr cx: @mark[point][0], cy: @mark[point][1]

    majorPath = "M #{@mark.p0[0]} #{@mark.p0[1]}, L #{@mark.p1[0]} #{@mark.p1[1]}"
    minorPath = "M #{@mark.p2[0]} #{@mark.p2[1]}, L #{@mark.p3[0]} #{@mark.p3[1]}"

    @cross.attr path: "#{majorPath}, #{minorPath}"

    [intersection] = Raphael.pathIntersection majorPath, minorPath

    @cross.attr 'stroke-dasharray': if intersection? then '' else '.'

    intersection ?=
      x: (@mark.p0[0] + @mark.p1[0]) / 2
      y: (@mark.p0[1] + @mark.p1[1]) / 2

    @controls.moveTo intersection.x, intersection.y

window.MarkingSurface.AxesTool = AxesTool
module?.exports = AxesTool
