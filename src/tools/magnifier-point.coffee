{Tool} = window?.MarkingSurface || require 'marking-surface'

class MagnifierPointTool extends Tool
  href: ''
  radius: 40
  zoom: 1.5

  stroke: 'white'
  strokeWidth: 2

  cursors:
    disc: '*grab'

  initialize: ->
    @href ||= @surface.el.querySelector('image').href.baseVal

    @clip = @addShape 'clipPath', id: "_#{Math.random().toString()[2...]}"
    @clipCircle = @clip.addShape 'circle'
    @image = @addShape 'image', clipPath: "url(##{@clip.attr 'id'})"
    @disc = @addShape 'circle.disc'

    @root.filter 'shadow'
    @redraw()

  onInitialClick: ->
    @onInitialDrag arguments...

  onInitialDrag: ->
    @['on *drag disc'] arguments...

  'on *drag disc': (e) ->
    @mark.set @pointerOffset e

  @::onInitialClick = @::onInitialDrag

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
    @group.attr 'transform', "translate(#{@mark.x}, #{@mark.y})"
    pctX = @mark.x / @surface.el.clientWidth
    pctY = @mark.y / @surface.el.clientHeight
    width = @image.attr 'width'
    height = @image.attr 'height'
    @clipCircle.attr 'transform', "translate(#{width * pctX}, #{height * pctY})"
    @image.attr 'transform', "translate(#{width * -pctX}, #{height * -pctY})"
    @controls.moveTo @mark.x, @mark.y

window?.MarkingSurface.MagnifierPointTool = MagnifierPointTool
module?.exports = MagnifierPointTool
