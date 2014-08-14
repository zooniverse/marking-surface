{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  selectedRadius: 40
  deselectedRadius: 8
  strokeWidth: 1
  crosshairsSpan: 4 / 5

  href: ''
  zoom: 2

  startOffset: null

  constructor: ->
    super

    clipID = 'marking-surface-magnifier-clip-' + Math.random().toString().split('.')[1]

    @clip = @addShape 'clipPath', id: clipID
    @clipCircle = @clip.addShape 'circle'

    @image = @addShape 'image', clipPath: "url(##{clipID})"
    @crosshairs = @addShape 'path.crosshairs', stroke: 'currentColor'
    @disc = @addShape 'circle.disc', fill: 'transparent', stroke: 'currentColor'

    @addEvent 'marking-surface:element:start', 'circle', @onStart
    @addEvent 'marking-surface:element:move', 'circle', @onMove

    setTimeout =>
      @href ||= @markingSurface.el.querySelector('image').href.baseVal
      @image.attr 'xlink:href': @href

  onInitialStart: (e) ->
    {x, y} = @coords e

    @mark.x = x
    @mark.y = y

    @onStart arguments...
    @onInitialMove arguments...

  onInitialMove: ->
    @onMove arguments...

  onStart: (e) ->
    {x, y} = @coords e

    @startOffset =
      x: x - @mark.x
      y: y - @mark.y

  onMove: (e) ->
    {x, y} = @coords e
    x -= @startOffset.x
    y -= @startOffset.y
    @mark.set {x, y}

  select: ->
    super
    @render()

  deselect: ->
    super
    @render()

  render: ->
    super

    currentRadius = if @markingSurface.selection is this
      @selectedRadius
    else
      @deselectedRadius

    scale = (@markingSurface?.scaleX + @markingSurface?.scaleY) / 2
    scaledRadius = currentRadius / scale
    scaledStrokeWidth = @strokeWidth / scale
    width = @markingSurface.el.offsetWidth / scale
    height = @markingSurface.el.offsetHeight / scale

    @clipCircle.attr
      transform: "translate(#{@mark.x * @zoom}, #{@mark.y * @zoom})"
      r: scaledRadius

    @image.attr
      width: width * @zoom
      height: height * @zoom
      transform: "translate(#{-1 * @mark.x * @zoom}, #{-1 * @mark.y * @zoom})"

    @crosshairs.attr
      strokeWidth: scaledStrokeWidth * @strokeWidth
      d: """
        M #{-scaledRadius * @crosshairsSpan} 0 L #{scaledRadius * @crosshairsSpan} 0
        M 0 #{-scaledRadius * @crosshairsSpan} L 0 #{scaledRadius * @crosshairsSpan}
      """

    @disc.attr
      r: scaledRadius
      strokeWidth: scaledStrokeWidth

    @attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    @controls?.moveTo @getControlsPosition()...

  getControlsPosition: ->
    [@mark.x, @mark.y]

window?.MarkingSurface.MagnifierPointTool = MagnifierPointTool
module?.exports = MagnifierPointTool
