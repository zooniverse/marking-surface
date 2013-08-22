{ToolControls, RectangleTool} = window?.MarkingSurface || require 'marking-surface'

class TranscriptionControls extends ToolControls
  constructor: ->
    super

    @deleteButton.style.position = 'absolute'
    @deleteButton.style.right = '0.5em'
    @deleteButton.style.top = '-1.5em'

    @textarea = document.createElement 'textarea'
    @textarea.style.height = '3em'
    @textarea.style.width = '100%'
    @textarea.addEventListener 'keydown', @onKeyDown, false

    @el.appendChild @textarea

  onKeyDown: (e) =>
    setTimeout =>
      @tool.mark.set 'content', @textarea.value

  onToolSelect: ->
    super
    @textarea.style.display = ''

  onToolDeselect: ->
    super
    @textarea.style.display = 'none'

  render: ->
    @el.style.width = "#{@tool.mark.width}px"

class TranscriptionTool extends RectangleTool
  @Controls: TranscriptionControls

  initialize: ->
    super
    @mark.set 'content', ''

  positionControls: ->
    @controls.moveTo @mark.left,  @mark.top + @mark.height, true

window?.MarkingSurface.TranscriptionTool = TranscriptionTool
module?.exports = TranscriptionTool
