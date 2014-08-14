{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  selectedRadius: 40
  deselectedRadius: 8
  strokeWidth: 1
  crosshairsSpan: 4 / 5

  tag: 'g.magnifier-point-tool'
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

    @disc.addEvent 'marking-surface:element:start', [@, 'onStart']
    @disc.addEvent 'marking-surface:element:move', [@, 'onMove']
    @disc.addEvent 'marking-surface:element:release', [@, 'onRelease']

    setTimeout =>
      @href ||= @markingSurface.el.querySelector('image').href.baseVal
      @image.attr 'xlink:href': @href

  onInitialStart: (e) ->
    super

    {x, y} = @coords e

    @mark.x = x
    @mark.y = y

    @onStart arguments...
    @onInitialMove arguments...

  onInitialMove: ->
    super
    @onMove arguments...

  onInitialRelease: ->
    super
    @onRelease arguments...

  onStart: (e) ->
    {x, y} = @coords e

    @startOffset =
      x: x - @mark.x
      y: y - @mark.y

    @attr 'data-active', true

  onMove: (e) ->
    {x, y} = @coords e
    x -= @startOffset.x
    y -= @startOffset.y
    @mark.set {x, y}

  onRelease: ->
    @attr 'data-active', null

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
    width = @markingSurface.el.offsetWidth / @markingSurface?.scaleX
    height = @markingSurface.el.offsetHeight / @markingSurface?.scaleY

    if @mark.x? and @mark.y?
      @clipCircle.attr
        transform: "translate(#{@mark.x * @zoom}, #{@mark.y * @zoom})"
        r: scaledRadius

      @image.attr
        transform: "translate(#{-1 * @mark.x * @zoom}, #{-1 * @mark.y * @zoom})"
        width: width * @zoom
        height: height * @zoom

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

MarkingSurface.insertStyle 'marking-surface-magnifier-point-tool-default-style', '''
  .magnifier-point-tool {
    cursor: move;
    cursor: -moz-grab;
    cursor: -webkit-grab;
    cursor: grab;
  }

  .magnifier-point-tool[data-active] {
    cursor: move;
    cursor: -moz-grabbing;
    cursor: -webkit-grabbing;
    cursor: grabbing;
  }
'''

window?.MarkingSurface.MagnifierPointTool = MagnifierPointTool
module?.exports = MagnifierPointTool
