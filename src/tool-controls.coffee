class ToolControls extends BaseClass
  tool: null

  el: null
  handle: null
  label: null
  deleteButton: null

  template: '''
    <div class="marking-tool-controls">
      <span class="handle"></span>
      <span class="label"></span>
      <button name="delete-mark">&times;</button>
    </div>
  '''

  constructor: ->
    super

    @el = $(@template)

    @handle = @el.find '.handle'
    @label = @el.find '.label'
    @deleteButton = @el.find 'button[name="delete-mark"]'

    @el.on 'mousedown', =>
      @tool.select()

    @el.on 'click', 'button[name="delete-mark"]', =>
      @onClickDelete arguments...

    @tool.on 'select', =>
      @onToolSelect arguments...

    @tool.on 'deselect', =>
      @onToolDeselect arguments...

    @tool.mark.on 'change', =>
      @label.html @tool.mark.label if 'label' of @tool.mark
      @render()

    @tool.on 'destroy', =>
      @destroy()

  moveTo: (x, y) ->
    [x, y] = x if x instanceof Array

    if x > @tool.surface.width / 2
      x -= @el.width()
      @el.addClass 'to-the-left'
    else
      @el.removeClass 'to-the-left'

    # Use margins to avoid problems with a parent's padding.
    @el.css
      left: 0
      'margin-left': x
      'margin-top': y
      position: 'absolute'
      top: 0

  onToolSelect: ->
    @el.addClass 'selected'

  onToolDeselect: ->
    @el.removeClass 'selected'

  onClickDelete: ->
    @tool.mark.destroy()

  destroy: ->
    @el.off()
    @el.remove()

  render: =>
    # Do whatever makes sense here.
