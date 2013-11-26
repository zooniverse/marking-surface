{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  href: ''
  radius: 40
  zoom: 1.5

  stroke: 'white'
  strokeWidth: 2

  cursors:
    disc: '*grab'

  startOffset: null

  initialize: ->
    @href ||= @surface.el.querySelector('image').href.baseVal

    @clip = @addShape 'clipPath', id: "_#{Math.random().toString()[2...]}"
    @clipCircle = @clip.addShape 'circle'
    @image = @addShape 'image', clipPath: "url(##{@clip.attr 'id'})"
    @disc = @addShape 'circle.disc'

    @root.filter 'shadow'
    @redraw()

  onInitialClick: ->
    @['on *start disc'] arguments...

  onInitialDrag: ->
    @['on *drag disc'] arguments...

  'on *start disc': (e) ->
    offset = @pointerOffset e
    @startOffset =
      x: (offset.x - @mark.x) || 0
      y: (offset.y - @mark.y) || 0

    @['on *drag disc'] arguments...

  'on *drag disc': (e) ->
    {x, y} = @pointerOffset e
    x -= @startOffset.x
    y -= @startOffset.y
    @mark.set {x, y}

  redraw: ->
    @clipCircle.attr 'r', @radius

    img = new Image
    img.onload = =>
      {width, height} = img
      @image.attr
        'xlink:href': @href
        width: width * @zoom
        height: height * @zoom

    img.src = @href

    @disc.attr
      r: @radius
      stroke: @stroke
      strokeWidth: @strokeWidth

    @render()

  render: ->
    if @mark.x? and @mark.y?
      @group.attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
      @controls.moveTo @getControlsPosition()...

      width = @image.attr 'width'
      height = @image.attr 'height'

      if width? and height?
        pctX = @mark.x / @surface.el.clientWidth
        pctY = @mark.y / @surface.el.clientHeight
        @clipCircle.attr 'transform', "translate(#{width * pctX}, #{height * pctY})"
        @image.attr 'transform', "translate(#{width * -pctX}, #{height * -pctY})"

  getControlsPosition: ->
    [@mark.x, @mark.y]

window?.MarkingSurface.MagnifierPointTool = MagnifierPointTool
module?.exports = MagnifierPointTool
