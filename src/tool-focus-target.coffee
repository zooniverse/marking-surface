KEYS =
  esc: 27
  delete: 8

class ToolFocusTarget extends ElementBase
  tag: 'button.marking-surface-tool-focus-target'

  constructor: ->
    super

    @tool.on 'focus', [@el, 'focus']
    @tool.on 'select', [@, 'toFront']
    @tool.on 'destroy', [@, 'destroy']
    @addEvent 'focus', [@tool, 'focus']
    @addEvent 'click', [@tool, 'select'] # This handles space and return keys.
    @addEvent 'blur', [@tool, 'blur']
    @addEvent 'keydown', @onKeydown

  onKeydown: (e) ->
    return if e.metaKey or e.ctrlKey or e.altKey
    switch e.which
      when KEYS.delete
        siblingFocusTargets = @el.parentNode.children
        index = Array::indexOf.call siblingFocusTargets, @el
        @tool.mark.destroy()
        next = siblingFocusTargets[index % siblingFocusTargets.length]
        next?.focus()

      when KEYS.esc
        @tool.markingSurface.selection?.deselect()

      else noShortcutCalled = true
    e.preventDefault() unless noShortcutCalled
