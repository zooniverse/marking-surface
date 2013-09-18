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
    @el.style.cursor = 'auto'
    @el.innerHTML = @template

    @el.addEventListener 'mousedown', @onMouseDown, false

    @deleteButton = @el.querySelector "button[name='#{@deleteButtonName}']"
    @deleteButton?.addEventListener 'click', @onClickDelete, false

    @tool.on 'initial-release', @onToolInitialRelease
    @tool.on 'select', @onToolSelect
    @tool.mark.on 'change', @onMarkChange
    @tool.on 'deselect', @onToolDeselect
    @tool.on 'destroy', @onToolDestroy

    @tool.surface.el.appendChild @el

  onToolInitialRelease: =>
    toggleClass @el, 'tool-is-complete', @tool.isComplete()
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
    toggleClass @el, 'tool-selected', true
    null

  onMarkChange: =>
    @render arguments...
    null

  onToolDeselect: =>
    toggleClass @el, 'tool-selected', false
    null

  onToolDestroy: =>
    @destroy()
    null

  destroy: ->
    @el.removeEventListener 'mousedown', @onMouseDown, false
    @deleteButton?.removeEventListener 'click', @onClickDelete, false
    @el.parentNode.removeChild @el
    super
    null

  moveTo: (x, y, dontTryAndBeClever = false) ->
    {zoomBy, panX, panY, width, height} = @tool.surface

    panX *= width - (width / zoomBy)
    panY *= height - (height / zoomBy)

    [left, right] = if dontTryAndBeClever or x < width / 2
      [(x * zoomBy) - (panX * zoomBy), null]
    else
      [null, width - ((x * zoomBy) - (panX * zoomBy))]

    [top, bottom] = if dontTryAndBeClever or y < height / 2
      [(y * zoomBy) - (panY * zoomBy), null]
    else
      [null, height - ((y * zoomBy) - (panY * zoomBy))]

    @el.style.left    = if left?   then "#{Math.floor left}px"   else ''
    @el.style.right   = if right?  then "#{Math.floor right}px"  else ''
    @el.style.top     = if top?    then "#{Math.floor top}px"    else ''
    @el.style.bottom  = if bottom? then "#{Math.floor bottom}px" else ''

    toggleClass @el, 'opens-right', left?
    toggleClass @el, 'opens-left', right?
    toggleClass @el, 'opens-down', top?
    toggleClass @el, 'opens-up', bottom?

    null

  render: ->
    # Reflect the state of the tool's mark.
