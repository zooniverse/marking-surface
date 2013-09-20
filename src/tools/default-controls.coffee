{ToolControls} = window?.MarkingSurface || require 'marking-surface'

class DefaultToolControls extends ToolControls
  constructor: ->
    super
    @deleteButton = document.createElement 'button'
    @deleteButton.innerHTML = '&times;'
    @deleteButton.onclick = => @tool.mark.destroy()
    @el.appendChild @deleteButton

window?.MarkingSurface.DefaultToolControls = DefaultToolControls
module?.exports = DefaultToolControls
