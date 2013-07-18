{Tool} = window.MarkingSurface

dotRadius = if 'Touch' of window then 20 else 10

class AxesTool extends Tool
  lines: null
  dots: null

  markDefaults:
    p0: [-(dotRadius * 2), -(dotRadius * 2)], p1: [-(dotRadius * 2), -(dotRadius * 2)]
    p2: [-(dotRadius * 2), -(dotRadius * 2)], p3: [-(dotRadius * 2), -(dotRadius * 2)]

  color: [127, 255, 0]

  cursors:
    'dots': 'move'

  initialize: ->
    @lines = for i in [0...2]
      @addShape 'line', stroke: "rgb(#{@color})", strokeWidth: 2

    @dots = for i in [0...4]
      @addShape 'circle', r: dotRadius, fill: "rgba(#{@color}, 0.25)", stroke: "rgb(#{@color})", strokeWidth: 2

  onFirstClick: (e) ->
    {x, y} = @pointerOffset e
    points = if @drags is 0 then ['p0', 'p1', 'p2', 'p3'] else ['p2', 'p3']
    @mark.set point, [x, y] for point in points

  onFirstDrag: (e) ->
    {x, y} = @pointerOffset e
    points = if @drags is 0 then ['p1', 'p3'] else ['p3']
    @mark.set point, [x, y] for point in points

  isComplete: ->
    @drags is 2

  downedDot = NaN
  'on drag dots': (e) =>
    {x, y} = @pointerOffset e

    index = i for s, i in @dots when s.el is e.target

    @downedDot = index if e.type in ['mousedown', 'touchstart']

    @mark.set "p#{@downedDot}", [x, y]

  render: ->
    for point, i in ['p0', 'p1', 'p2', 'p3']
      @dots[i].attr cx: @mark[point][0], cy: @mark[point][1]

    @lines[0].attr x1: @mark.p0[0], y1: @mark.p0[1], x2: @mark.p1[0], y2: @mark.p1[1]
    @lines[1].attr x1: @mark.p2[0], y1: @mark.p2[1], x2: @mark.p3[0], y2: @mark.p3[1]

    # [intersection] = Raphael.pathIntersection majorPath, minorPath

    for line in @lines
      line.attr 'strokeDasharray': if intersection? then '' else '2, 2'

    intersection =
      x: (@mark.p0[0] + @mark.p1[0]) / 2
      y: (@mark.p0[1] + @mark.p1[1]) / 2

    @controls.moveTo intersection.x, intersection.y

window?.MarkingSurface.AxesTool = AxesTool
module?.exports = AxesTool
