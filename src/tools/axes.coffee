{Tool} = window?.MarkingSurface || require 'marking-surface'

class AxesTool extends Tool
  lines: null
  dots: null

  handleRadius: if !!~navigator.userAgent.indexOf 'iO' then 20 else 10
  fill: 'rgba(128, 128, 128, 0.1)'
  stroke: 'white'
  strokeWidth: 2

  cursors:
    'dots': 'move'

  initialize: ->
    @root.filter 'shadow'

    @lines = for i in [0...2]
      @addShape 'line', {@stroke, @strokeWidth}

    @dots = for i in [0...4]
      @addShape 'circle', {r: @handleRadius, @fill, @stroke, @strokeWidth}

    @mark.set
      p0: [-(@handleRadius * 2), -(@handleRadius * 2)]
      p1: [-(@handleRadius * 2), -(@handleRadius * 2)]
      p2: [-(@handleRadius * 2), -(@handleRadius * 2)]
      p3: [-(@handleRadius * 2), -(@handleRadius * 2)]

  onFirstClick: (e) ->
    {x, y} = @pointerOffset e
    points = if @drags is 0 then ['p0', 'p1', 'p2', 'p3'] else ['p2', 'p3']
    newValues = {}
    newValues[point] = [x, y] for point in points
    @mark.set newValues

  onFirstDrag: (e) ->
    {x, y} = @pointerOffset e
    points = if @drags is 0 then ['p1', 'p3'] else ['p3']
    newValues = {}
    newValues[point] = [x, y] for point in points
    @mark.set newValues

  isComplete: ->
    @drags is 2

  downedDotIndex: NaN
  'on *drag dots': (e) =>
    if e.type in ['mousedown', 'touchstart']
      @downedDotIndex = i for s, i in @dots when s.el is e.target

    {x, y} = @pointerOffset e
    @mark.set "p#{@downedDotIndex}", [x, y]

  render: ->
    for point, i in ['p0', 'p1', 'p2', 'p3']
      @dots[i].attr cx: @mark[point][0], cy: @mark[point][1]

    @lines[0].attr x1: @mark.p0[0], y1: @mark.p0[1], x2: @mark.p1[0], y2: @mark.p1[1]
    @lines[1].attr x1: @mark.p2[0], y1: @mark.p2[1], x2: @mark.p3[0], y2: @mark.p3[1]

    intersection = if @mark.p0[0] is @mark.p2[0] and @mark.p0[1] is @mark.p2[1]
      null
    else
      @getIntersection @mark.p0, @mark.p1, @mark.p2, @mark.p3

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
