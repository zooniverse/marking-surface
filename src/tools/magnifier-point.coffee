{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  selectedRadius: if @mobile then 60 else 40
  deselectedRadius: if @mobile then 20 else 10
  strokeWidth: 2
  crosshairsWidth: 1
  crosshairsGap: 0.2
  closeButtonRadius: if @mobile then 15 else 7

  tag: 'g.magnifier-point-tool'
  href: ''
  zoom: 2

  startOffset: null

  constructor: ->
    super

    radiusAt45Deg = @selectedRadius * Math.sin 45 / (180 / Math.PI)

    @root.attr 'transform', 'translate(-0.5, -0.5)'

    clipID = 'marking-surface-magnifier-clip-' + Math.random().toString().split('.')[1]

    @clip = @addShape 'clipPath', id: clipID
    @clipCircle = @clip.addShape 'circle'

    @image = @addShape 'image', clipPath: "url(##{clipID})"
    @crosshairs = @addShape 'path.crosshairs', stroke: 'currentColor'
    @disc = @addShape 'circle.disc', fill: 'transparent', stroke: 'currentColor'

    @disc.addEvent 'marking-surface:element:start', [@, 'onStart']
    @disc.addEvent 'marking-surface:element:move', [@, 'onMove']
    @disc.addEvent 'marking-surface:element:release', [@, 'onRelease']

    @closeButtonGroup = @addShape 'g.button', strokeWidth: @strokeWidth, transform: "translate(#{radiusAt45Deg}, #{-1 * radiusAt45Deg})"
    @closeButtonGroup.addShape 'circle', r: @closeButtonRadius, fill: 'black', stroke: 'currentColor'
    @closeButtonGroup.addShape 'path', d: "
      M #{-0.7 * @closeButtonRadius} 0 L #{0.7 * @closeButtonRadius} 0
      M 0 #{-0.7 * @closeButtonRadius} L 0 #{0.7 * @closeButtonRadius}
    ", stroke: 'white', transform: 'rotate(-45)'

    @closeButtonGroup.addEvent 'click', [@mark, 'destroy']

    @deselectButtonGroup = @addShape 'g.button', strokeWidth: @strokeWidth, transform: "translate(#{@selectedRadius}, 0)"
    @deselectButtonGroup.addShape 'circle', r: @closeButtonRadius, fill: 'black', stroke: 'currentColor'
    @magnifyIcon = @deselectButtonGroup.addShape 'g', stroke: 'white', transform: 'rotate(45)'
    @magnifyIcon.addShape 'circle', r: @closeButtonRadius / 3
    @magnifyIcon.addShape 'path', d: "M #{@closeButtonRadius / 3} 0 L #{@closeButtonRadius} 0"

    @deselectButtonGroup.addEvent 'click', [@, 'deselect']

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

    width = @markingSurface.el.offsetWidth / @markingSurface?.scaleX
    height = @markingSurface.el.offsetHeight / @markingSurface?.scaleY

    if @mark.x? and @mark.y?
      @clipCircle.attr
        transform: "translate(#{@mark.x * @zoom}, #{@mark.y * @zoom})"
        r: currentRadius

      @image.attr
        transform: "translate(#{-1 * @mark.x * @zoom}, #{-1 * @mark.y * @zoom})"
        width: width * @zoom
        height: height * @zoom
        opacity: if isSelected then 1 else 0

      @crosshairs.attr
        strokeWidth: if isSelected then @crosshairsWidth else @strokeWidth
        d: """
          M #{-currentRadius} 0 L #{-1 * currentRadius * @crosshairsGap} 0
          M #{currentRadius * @crosshairsGap} 0 L #{currentRadius} 0
          M 0 #{-currentRadius} L 0 #{-1 * currentRadius * @crosshairsGap}
          M 0 #{currentRadius * @crosshairsGap} L 0 #{currentRadius}
        """

      @disc.attr
        r: currentRadius
        strokeWidth: if isSelected then @strokeWidth else 0

      @attr 'transform', "translate(#{@mark.x}, #{@mark.y}) scale(#{1 / @markingSurface.scaleX}, #{1 / @markingSurface.scaleY})"
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

  .magnifier-point-tool .button {
    cursor: pointer;
  }

  .magnifier-point-tool:not([data-selected]) .button {
    display: none
  }
'''

window?.MarkingSurface.MagnifierPointTool = MagnifierPointTool
module?.exports = MagnifierPointTool
