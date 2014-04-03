{Tool} = window?.MarkingSurface || require 'marking-surface'

class AxesTool extends Tool
  strokeWidth: 2
  radius: if @mobile then 20 else 10

  constructor: ->
    super

    @lines = for i in [0...2]
      @addShape 'line.axis', stroke: 'currentColor'

    @handles = for i in [0...4]
      @mark["p#{i}"] = [-2 * @radius, -2 * @radius]
      handle = @addShape 'circle.handle', fill: 'currentColor', 'data-handle-index': i
      handle

    @addEvent 'move', '.handle', [this, @onHandleMove]
    @addEvent 'release', '.handle', [this, @onHandleRelease]

  rescale: (scale) ->
    super

    for line in @lines
      line.attr 'strokeWidth', @strokeWidth / scale

    for handle in @handles
      handle.attr 'r', @radius / scale

  onInitialStart: (e) ->
    {x, y} = @coords e
    points = if @movements is 0 then ['p0', 'p1'] else ['p2', 'p3']
    for point in points
      @mark.set point, [x, y]

  onInitialMove: (e) ->
    {x, y} = @coords e
    point = if @movements is 0 then 'p1' else 'p3'
    @mark.set point, [x, y]

  isComplete: ->
    @movements is 2

  # Store the moving handle outside the method or we'll lose it when the cursor slips off.
  handleIndex = null

  onHandleMove: (e) ->
    handleIndex ?= e.target.getAttribute 'data-handle-index'
    {x, y} = @coords e
    @mark.set "p#{handleIndex}", [x, y]

  onHandleRelease: ->
    handleIndex = null

  render: ->
    @lines[0].attr
      x1: @mark.p0[0], y1: @mark.p0[1]
      x2: @mark.p1[0], y2: @mark.p1[1]

    @lines[1].attr
      x1: @mark.p2[0], y1: @mark.p2[1]
      x2: @mark.p3[0], y2: @mark.p3[1]

    for point, i in ['p0', 'p1', 'p2', 'p3']
      @handles[i].attr cx: @mark[point][0], cy: @mark[point][1]

    intersection = if @movements < 1
      null
    else
      @getIntersection @mark.p0, @mark.p1, @mark.p2, @mark.p3

    if intersection?
      @el.setAttribute 'data-intersects', true
    else
      @el.removeAttribute 'data-intersects'

    intersection ?= if @movements is 0
      [
        (@mark.p0[0] + @mark.p1[0]) / 2
        (@mark.p0[1] + @mark.p1[1]) / 2
      ]
    else
      [
        (@mark.p0[0] + @mark.p1[0] + @mark.p2[0] + @mark.p3[0]) / 4
        (@mark.p0[1] + @mark.p1[1] + @mark.p2[1] + @mark.p3[1]) / 4
      ]

    @controls.moveTo
      x: intersection[0]
      y: intersection[1]

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
