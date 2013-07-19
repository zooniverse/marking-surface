{Tool} = window.MarkingSurface

dotRadius = if 'Touch' of window then 20 else 10

class AxesTool extends Tool
  lines: null
  dots: null

  markDefaults:
    type: 'AXES'
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

    intersection = @getIntersection @mark.p0, @mark.p1, @mark.p2, @mark.p3

    for line in @lines
      line.attr 'strokeDasharray': if intersection? then '' else '2, 2'

    intersection ?= [
      (@mark.p0[0] + @mark.p1[0] + @mark.p2[0] + @mark.p3[0]) / 4
      (@mark.p0[1] + @mark.p1[1] + @mark.p2[1] + @mark.p3[1]) / 4
    ]

    @controls.moveTo intersection...

  getIntersection: (p0, p1, p2, p3) ->
      grads = [
        (p0[1] - p1[1]) / ((p0[0] - p1[0]) || 0.00001)
        (p2[1] - p3[1]) / ((p2[0] - p3[0]) || 0.00001)
      ]

      interX = ((p2[1] - p0[1]) + (grads[0] * p0[0] - grads[1] * p2[0])) / (grads[0] - grads[1])
      interY = grads[0] * (interX - p0[0]) + p0[1]

      sortedX = [p0[0], p1[0], p2[0], p3[0], interX].sort (a, b) -> a - b
      sortedY = [p0[1], p1[1], p2[1], p3[1], interY].sort (a, b) -> a - b

      interX = NaN unless sortedX[2] is interX
      interY = NaN unless sortedY[2] is interY

      if (isNaN interX) or (isNaN interY)
        null
      else
        [interX, interY]

window?.MarkingSurface.AxesTool = AxesTool
module?.exports = AxesTool
