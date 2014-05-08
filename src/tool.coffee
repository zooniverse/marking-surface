class Tool extends SVG
  @Mark: Mark
  @Controls: null
  @mobile: !!navigator.userAgent.match /iP|droid/

  tag: 'g.marking-surface-tool'

  markingSurface: null

  movements: 0

  constructor: ->
    super

    unless @mark?
      @mark = new @constructor.Mark

    @mark.on 'marking-surface:mark:change', [@, 'render']
    @mark.on 'marking-surface:mark:change', [@, 'trigger', 'marking-surface:mark:change'] # Faux-bubbling
    @mark.on 'marking-surface:base:destroy', [@, 'destroy']

    @focusTarget = new ToolFocusTarget
      tool: this

    @controls = if @constructor.Controls?
      controls = new @constructor.Controls
        tool: this

    @focusRoot = SVG::addShape.call @, 'g.marking-surface-tool-focus-root'
    @selectedRoot = @focusRoot.addShape 'g.marking-surface-tool-selected-root'
    @root = @selectedRoot.addShape 'g.marking-surface-tool-root'

  addShape: ->
    @root.addShape arguments...

  coords: (e) ->
    @markingSurface.screenPixelToScale @markingSurface.sizeRect.pointerOffset e

  _onStart: (e) ->
    e.preventDefault()
    @select()
    super

  handleEvent: ->
    unless @markingSurface.disabled
      super

  # NOTE: These "initial" events originate on the marking surface.

  onInitialStart: (e) ->
    @select()
    @trigger 'marking-surface:tool:initial-click', [e]

  onInitialMove: (e) ->
    @trigger 'marking-surface:tool:initial-drag', [e]

  onInitialRelease: (e) ->
    @movements += 1
    @trigger 'marking-surface:tool:initial-release', [e]

  rescale: (scaleX, scaleY) ->
    @render()

  render: ->
    @attr 'data-complete', @isComplete() || null

  isComplete: ->
    # Override this if drawing the tool requires multiple drag steps (e.g. axes).
    @movements is 1

  focus: ->
    @attr 'data-focused', true
    @trigger 'marking-surface:tool:focus'

  blur: ->
    @attr 'data-focused', null
    @trigger 'marking-surface:tool:blur'

  select: ->
    @focus()
    @toFront()
    @attr 'data-selected', true
    @trigger 'marking-surface:tool:select'

  deselect: ->
    @attr 'data-selected', null
    @trigger 'marking-surface:tool:deselect'

  destroy: ->
    @deselect()
    super
    @root.destroy()
    @selectedRoot.destroy()
    @focusRoot.destroy()

Tool.defaultStyle = insertStyle 'marking-surface-tool-default-style', """
  .marking-surface-tool[data-focused] .marking-surface-tool-focus-root {
    filter: url(##{FILTER_ID_PREFIX}focus);
  }

  .marking-surface-tool[data-selected] .marking-surface-tool-selected-root {
    filter: url(##{FILTER_ID_PREFIX}shadow);
  }
"""
