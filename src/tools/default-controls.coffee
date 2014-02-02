{ToolControls} = window?.MarkingSurface || require 'marking-surface'

class DefaultToolControls extends ToolControls
  template: '''
    <button name="destroy">&times;</button>
  '''

  constructor: ->
    super
    @addEvent 'click', 'button[name="destroy"]', => @tool.mark.destroy()

window?.MarkingSurface.DefaultToolControls = DefaultToolControls
module?.exports = DefaultToolControls
