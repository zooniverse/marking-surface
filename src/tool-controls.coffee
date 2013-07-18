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
    addEvent @deleteButton, 'click', @onClickDelete

    @tool.on 'select', @onToolSelect

    @tool.on 'initial-release', =>
      @el.classList.add 'complete' if @tool.isComplete()

    @tool.mark.on 'change', @render

    @tool.on 'deselect', @onToolDeselect

    @tool.on 'destroy', @onToolDestroy

  moveTo: (x, y) ->
    # [x, y] = x if x instanceof Array

    # if x > @tool.surface.width / 2
    #   @el.classList.add 'to-the-left'
    #   @el.css
    #     left: ''
    #     position: 'absolute'
    #     right: @tool.surface.width - x
    #     top: y

    # else
    #   @el.classList.remove 'to-the-left'
    #   @el.css
    #     left: x
    #     position: 'absolute'
    #     right: ''
    #     top: y

  onMouseDown: =>
    return if @tool.surface.disabled
    @tool.select()

  onClickDelete: (e) =>
    return if @tool.surface.disabled
    e.preventDefault()
    @tool.mark.destroy()

  onToolSelect: =>
    @el.classList.add 'selected'

  onToolDeselect: =>
    @el.classList.remove 'selected'

  onToolDestroy: =>
    @destroy()

  destroy: ->
    removeEvent @el, 'mousedown', @onMouseDown
    removeEvent @deleteButton, 'click', @onClickDelete
    @el.parentNode.removeChild @el

  render: =>
    # Do whatever makes sense here.
    @label.innerHTML = @tool.mark._label if '_label' of @tool.mark
