{ToolControls, RectangleTool} = window?.MarkingSurface || require 'marking-surface'

class TranscriptionControls extends ToolControls
  constructor: ->
    super

    @textarea = document.createElement 'textarea'
    @textarea.style.height = '3em'
    @textarea.style.width = '100%'
    @textarea.addEventListener 'input', @onChangeTextarea, false

    @el.appendChild @textarea

  onChangeTextarea: (e) =>
    setTimeout =>
      @tool.mark.set 'content', @textarea.value

  onToolSelect: ->
    super
    @textarea.style.display = ''
    setTimeout => @textarea.focus()

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
    @controls.moveTo @mark.left + (@mark.width / 2),  @mark.top + @mark.height, true

window?.MarkingSurface.TranscriptionTool = TranscriptionTool
module?.exports = TranscriptionTool
