{ToolControls, RectangleTool} = window?.MarkingSurface || require 'marking-surface'

class TranscriptionControls extends ToolControls
  template: '''
    <textarea style="height: 3em; width: 100%"></textarea>
  '''

  constructor: ->
    super
    @textarea = @el.querySelector 'textarea'
    @addEvent 'input', 'textarea', @onChangeTextarea

  onChangeTextarea: (e) ->
    @tool.mark.set 'content', @textarea.value

  onToolSelect: ->
    super
    @textarea.style.display = ''

  onToolDeselect: ->
    super
    @textarea.style.display = 'none'

  render: ->
    super
    @el.style.width = "#{@tool.mark.width}px"

class TranscriptionTool extends RectangleTool
  @Controls: TranscriptionControls

  constructor: ->
    super
    @mark.content = ''

  onInitialRelease: ->
    super
    @controls?.textarea.focus()

  render: ->
    super
    @controls?.moveTo
      x: @mark.left + (@mark.width / 2)
      y: @mark.top + @mark.height

window?.MarkingSurface.TranscriptionTool = TranscriptionTool
module?.exports = TranscriptionTool
