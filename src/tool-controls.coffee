class ToolControls extends BaseClass
  tool: null

  el: null
  className: 'marking-tool-controls'
  label: null
  deleteButton: null

  template: '''
    <span class="tool-label"></span>
    <button name="delete-mark">&times;</button>
  '''

  constructor: ->
    super

    @el = document.createElement 'div'
    @el.className = @className
    @el.innerHTML = (@template? @) || @template

    @label = @el.querySelector '.tool-label'
    @deleteButton = @el.querySelector 'button[name="delete-mark"]'

    @el.addEventListener 'mousedown', @onMouseDown, false
    @deleteButton.addEventListener 'click', @onClickDelete, false if @deleteButton?

    @tool.on 'select', @onToolSelect

    @tool.on 'initial-release', =>
      @el.setAttribute 'complete', 'complete' if @tool.isComplete()

    @tool.mark.on 'change', @render

    @tool.on 'deselect', @onToolDeselect

    @tool.on 'destroy', @onToolDestroy

  moveTo: (x, y) ->
    {zoomBy, panX, panY, width, height} = @tool.surface

    @el.style.position = 'absolute'

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

    hidden = left < 0 or right < 0 or top < 0 or bottom < 0
    hidden ||= left > width or right > width or top > height or bottom > height

    @el.style.left    = if left?   then "#{left}px"   else ''
    @el.style.right   = if right?  then "#{right}px"  else ''
    @el.style.top     = if top?    then "#{top}px"    else ''
    @el.style.bottom  = if bottom? then "#{bottom}px" else ''
    @el.style.display = if hidden  then 'none'        else ''

    @el.setAttribute 'horizontal-direction', if left? then 'right' else 'left'
    @el.setAttribute 'vertical-direction',   if top?  then 'down'  else 'up'

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

  onToolDeselect: =>
    @el.removeAttribute 'selected'
    null

  onToolDestroy: =>
    @destroy()
    null

  destroy: ->
    super
    @el.removeEventListener 'mousedown', @onMouseDown, false
    @deleteButton.removeEventListener 'click', @onClickDelete, false
    @el.parentNode.removeChild @el
    null

  render: =>
    # Do whatever makes sense here.
    @label?.innerHTML = @tool.mark._label if '_label' of @tool.mark
    null
