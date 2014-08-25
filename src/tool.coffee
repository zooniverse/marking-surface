class Tool extends SVG
  @Mark: Mark
  @Controls: null
  @mobile: !!navigator.userAgent.match /iP|droid/

  tag: 'g.marking-surface-tool'

  markingSurface: null

  movements: 0

  focused: false

  fps: 60

  constructor: ->
    super

    unless @mark?
      @mark = new @constructor.Mark

    @mark.on 'marking-surface:mark:change', [@, 'throttleRender']
    @mark.on 'marking-surface:mark:change', [@, 'dispatchEvent', 'marking-surface:mark:change', [@mark]] # Faux-bubbling
    @mark.on 'marking-surface:base:destroy', [@, 'destroy']

    @focusTarget = new ToolFocusTarget
      tool: this

    @controls = if @constructor.Controls?
      controls = new @constructor.Controls
        tool: this

    @focusRoot = SVG::addShape.call this, 'g.marking-surface-tool-focus-root'
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
    @dispatchEvent 'marking-surface:tool:initial-click', [e]

  onInitialMove: (e) ->
    @dispatchEvent 'marking-surface:tool:initial-drag', [e]

  onInitialRelease: (e) ->
    @movements += 1
    @dispatchEvent 'marking-surface:tool:initial-release', [e]

  rescale: (scaleX, scaleY) ->
    @render()

  renderTimeout: NaN
  throttleRender: ->
    if isNaN @renderTimeout
      @render arguments...
      @renderTimeout = setTimeout (=> @renderTimeout = NaN), 1000 / @fps

  render: ->
    @attr 'data-complete', @isComplete() || null

  isComplete: ->
    # Override this if drawing the tool requires multiple drag steps (e.g. axes).
    @movements is 1

  focus: ->
    unless @focused
      @focused = true
      @attr 'data-focused', true
      @dispatchEvent 'marking-surface:tool:focus', [this]

  blur: ->
    if @focused
      @focused = false
      @attr 'data-focused', null
      @dispatchEvent 'marking-surface:tool:blur', [this]

  select: ->
    unless @markingSurface.selection is this
      @focus()
      @toFront()
      @attr 'data-selected', true
      @dispatchEvent 'marking-surface:tool:select', [this]

  deselect: ->
    if @markingSurface.selection is this
      @attr 'data-selected', null
      @dispatchEvent 'marking-surface:tool:deselect', [this]

  destroy: ->
    @deselect()
    @dispatchEvent 'marking-surface:tool:destroy', [this]
    super

# Tool.defaultStyle = insertStyle 'marking-surface-tool-default-style', """
#   .marking-surface-tool[data-focused] .marking-surface-tool-focus-root {
#     filter: url(##{FILTER_ID_PREFIX}focus);
#   }

#   .marking-surface-tool[data-selected] .marking-surface-tool-selected-root {
#     filter: url(##{FILTER_ID_PREFIX}shadow);
#   }
# """
