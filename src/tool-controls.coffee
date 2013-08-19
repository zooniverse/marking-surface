class ToolControls extends BaseClass
  tool: null

  tagName: 'div'
  className: 'marking-tool-controls'
  deleteButtonName: 'delete-marking-tool'
  el: null
  deleteButton: null

  template: """
    <button name="#{@::deleteButtonName}">&times;</button>
  """

  constructor: ->
    super

    @el = document.createElement @tagName
    @el.className = @className
    @el.style.position = 'absolute'
    @el.innerHTML = @template

    @el.addEventListener 'mousedown', @onMouseDown, false

    @deleteButton = @el.querySelector "button[name='#{@deleteButtonName}']"
    @deleteButton?.addEventListener 'click', @onClickDelete, false

    @tool.on 'initial-release', @onToolInitialRelease
    @tool.on 'select', @onToolSelect
    @tool.mark.on 'change', @onMarkChange
    @tool.on 'deselect', @onToolDeselect
    @tool.on 'destroy', @onToolDestroy

  onToolInitialRelease: =>
    @el.setAttribute 'complete', 'complete' if @tool.isComplete()
    null

  onMouseDown: =>
    return if @tool.surface.disabled
    @tool.select()
    null

  onClickDelete: (e) =>
    return if @tool.surface.disabled
    e.preventDefault()
    @tool.mark.destroy()
    null

  onToolSelect: =>
    @el.setAttribute 'selected', 'selected'
    null

  onMarkChange: =>
    @render arguments...
    null

  onToolDeselect: =>
    @el.removeAttribute 'selected'
    null

  onToolDestroy: =>
    @destroy()
    null

  destroy: ->
    @el.removeEventListener 'mousedown', @onMouseDown, false
    @deleteButton.removeEventListener 'click', @onClickDelete, false
    @el.parentNode.removeChild @el
    super
    null

  moveTo: (x, y) ->
    {zoomBy, panX, panY, width, height} = @tool.surface

    panX *= width - (width / zoomBy)
    panY *= height - (height / zoomBy)

    [left, right] = if x < width / 2
      [(x * zoomBy) - (panX * zoomBy), null]
    else
      [null, width - ((x * zoomBy) - (panX * zoomBy))]

    [top, bottom] = if y < height / 2
      [(y * zoomBy) - (panY * zoomBy), null]
    else
      [null, height - ((y * zoomBy) - (panY * zoomBy))]

    outOfBounds = left < 0 or right < 0 or top < 0 or bottom < 0
    outOfBounds ||= left > width or right > width or top > height or bottom > height

    @el.style.left    = if left?       then "#{left}px"   else ''
    @el.style.right   = if right?      then "#{right}px"  else ''
    @el.style.top     = if top?        then "#{top}px"    else ''
    @el.style.bottom  = if bottom?     then "#{bottom}px" else ''
    @el.style.display = if outOfBounds then 'none'        else ''

    @el.setAttribute 'horizontal-direction', if left? then 'right' else 'left'
    @el.setAttribute 'vertical-direction',   if top?  then 'down'  else 'up'

    null

  render: ->
    # Reflect the state of the tool's mark.
