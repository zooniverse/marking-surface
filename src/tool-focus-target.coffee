KEYS =
  esc: 27
  delete: 8

class ToolFocusTarget extends ToolControls
  tag: 'button.marking-surface-tool-focus-target'

  constructor: ->
    super

    @el.type = 'button'

    @tool.on 'marking-surface:tool:focus', [@el, 'focus']

    @addEvent 'focus', [@tool, 'focus']
    @addEvent 'blur', [@tool, 'blur']
    @addEvent 'click', [@tool, 'select'] # This also handles space and return keys.
    @addEvent 'keydown', 'onKeydown'

  onKeydown: (e) ->
    unless e.metaKey or e.ctrlKey or e.altKey
      switch e.which
        when KEYS.delete
          siblingFocusTargets = @el.parentNode.children
          index = Array::indexOf.call siblingFocusTargets, @el
          @tool.destroy()
          next = siblingFocusTargets[index % siblingFocusTargets.length]
          next?.focus()

        when KEYS.esc
          @tool.markingSurface.selection?.deselect()

        else
          noShortcutCalled = true

      unless noShortcutCalled
        e.preventDefault()

  followTool: ->
    @tool.markingSurface.toolFocusTargetsContainer?.el.appendChild @el

  render: ->
    # No-op
