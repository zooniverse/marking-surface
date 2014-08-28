{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  selectedRadius: if @mobile then 60 else 40
  deselectedRadius: if @mobile then 20 else 10
  strokeWidth: 2
  crosshairsWidth: 1
  crosshairsGap: 0.1
  closeButtonRadius: if @mobile then 15 else 7

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
    @crosshairs = @addShape 'path.crosshairs', stroke: 'currentColor', transform: 'translate(-0.5, -0.5)'
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

    isSelected = @markingSurface.selection is this

    currentRadius = if isSelected
      @selectedRadius
    else
      @deselectedRadius

    scale = (@markingSurface?.scaleX + @markingSurface?.scaleY) / 2
    scaledRadius = currentRadius / scale
    scaledStrokeWidth = @strokeWidth / scale
    scaledCrosshairsWidth = @crosshairsWidth / scale
    width = @markingSurface.el.offsetWidth / @markingSurface?.scaleX
    height = @markingSurface.el.offsetHeight / @markingSurface?.scaleY

    if @mark.x? and @mark.y?
      @clipCircle.attr
        transform: "translate(#{@mark.x * @zoom}, #{@mark.y * @zoom})"
        r: scaledRadius

      window.img = @image
      @image.attr
        transform: "translate(#{-1 * @mark.x * @zoom}, #{-1 * @mark.y * @zoom})"
        width: width * @zoom
        height: height * @zoom
        opacity: if isSelected then 1 else 0

      @crosshairs.attr
        strokeWidth: scaledCrosshairsWidth
        d: """
          M #{-scaledRadius} 0 L #{-1 * scaledRadius * @crosshairsGap} 0
          M #{scaledRadius * @crosshairsGap} 0 L #{scaledRadius} 0
          M 0 #{-scaledRadius} L 0 #{-1 * scaledRadius * @crosshairsGap}
          M 0 #{scaledRadius * @crosshairsGap} L 0 #{scaledRadius}
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
