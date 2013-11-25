{ToolControls} = window?.MarkingSurface || require 'marking-surface'

class DefaultToolControls extends ToolControls
  destroyButtonName: 'destroy'
  destroyButtonLabel: '&times;'

  constructor: ->
    super
    @deleteButton = document.createElement 'button'
    @deleteButton.name = @destroyButtonName
    @deleteButton.innerHTML = @destroyButtonLabel
    @deleteButton.onclick = => @tool.mark.destroy()
    @el.appendChild @deleteButton

window?.MarkingSurface.DefaultToolControls = DefaultToolControls
module?.exports = DefaultToolControls
