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
      @onMouseDown arguments...

    @el.on 'click', 'button[name="delete-mark"]', =>
      @onClickDelete arguments...

  onMarkChange: ->
    @label.html @tool.mark.label

  moveTo: (x, y) ->
    [x, y] = x if x instanceof Array

    # User margins to avoid problems with a parent's padding.
    @el.css
      left: 0
      'margin-left': x
      'margin-top': y
      position: 'absolute'
      top: 0

  onMouseDown: (e) ->
    @tool.select()

  onClickDelete: ->
    @tool.mark.destroy()

  select: ->
    @el.addClass 'selected'

  deselect: ->
    @el.removeClass 'selected'

  destroy: ->
    @el.off()
    @el.remove()
