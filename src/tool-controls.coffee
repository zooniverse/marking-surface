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
    @el.classList.add @className
    @el.classList.add @constructor::className
    @el.innerHTML = (@template? @) || @template

    @label = @el.querySelector '.tool-label'
    @deleteButton = @el.querySelector 'button[name="delete-mark"]'

    addEvent @el, 'mousedown', @onMouseDown
    addEvent @deleteButton, 'click', @onClickDelete if @deleteButton?

    @tool.on 'select', @onToolSelect

    @tool.on 'initial-release', =>
      @el.classList.add 'complete' if @tool.isComplete()

    @tool.mark.on 'change', @render

    @tool.on 'deselect', @onToolDeselect

    @tool.on 'destroy', @onToolDestroy

  moveTo: (x, y) ->
    {zoomBy, panX, panY, width, height} = @tool.surface

    @el.style.position = 'absolute'

    [left, right] = if x < width / 2
      @el.classList.remove 'to-the-left'
      [(x * zoomBy) - (panX * zoomBy), null]
    else
      @el.classList.add 'to-the-left'
      [null, width - ((x * zoomBy) - (panX * zoomBy))]

    [top, bottom] = if y < height / 2
      @el.classList.remove 'from-the-bottom'
      [(y * zoomBy) - (panY * zoomBy), null]
    else
      @el.classList.add 'from-the-bottom'
      [null, height - ((y * zoomBy) - (panY * zoomBy))]

    hidden = left < 0 or right < 0 or top < 0 or bottom < 0

    @el.style.left = if left? then "#{left}px" else ''
    @el.style.right = if right? then "#{right}px" else ''
    @el.style.top = if top? then "#{top}px" else ''
    @el.style.bottom = if bottom? then "#{bottom}px" else ''
    @el.style.display = if hidden then 'none' else ''
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
    @el.classList.add 'selected'
    null

  onToolDeselect: =>
    @el.classList.remove 'selected'
    null

  onToolDestroy: =>
    @destroy()
    null

  destroy: ->
    super
    removeEvent @el, 'mousedown', @onMouseDown
    removeEvent @deleteButton, 'click', @onClickDelete
    @el.parentNode.removeChild @el
    null

  render: =>
    # Do whatever makes sense here.
    @label?.innerHTML = @tool.mark._label if '_label' of @tool.mark
    null