class ElementBase extends BaseClass
  tag: 'div'

  disabled: false

  _startEvent: null

  constructor: ->
    @_eventListeners = {}
    @_delegatedListeners = {}

    super

    @_createEl() unless @el?

    @addEvent 'mousedown', @_onStart
    @addEvent 'touchstart', @_onStart

    @disable() if @disabled

  _createEl: ->
    [tagName, classNames...] = @tag.split '.'
    @el = document.createElement tagName
    @el.className = classNames.join ' '

  attr: (attribute, value) ->
    if arguments.length is 1
      @el.getAttribute attribute
    else
      if value?
        @el.setAttribute attribute, value
      else
        @el.removeAttribute attribute

    # Hack to make IE apply changes in attribute-selected styles.
    if 'msMatchesSelector' of document.body
      @el.style.display = 'none'
      @el.style.display = ''

  enable: (e) ->
    @disabled = false
    @attr 'disabled', null
    @trigger 'enable'

  disable: (e) ->
    @disabled = true
    @attr 'disabled', true
    @trigger 'disable'

  addEvent: (eventName, [delegate]..., handler) ->
    unless eventName of @_eventListeners or eventName of @_delegatedListeners
      @el.addEventListener eventName, @, false

    if delegate?
      @_delegatedListeners[eventName] ?= {}
      @_delegatedListeners[eventName][delegate] ?= []
      @_delegatedListeners[eventName][delegate].push handler
    else
      @_eventListeners[eventName] ?= []
      @_eventListeners[eventName].push handler

  _onStart: (e) ->
    @_startEvent = e
    addEventListener 'mousemove', @, false
    addEventListener 'mouseup', @, false
    addEventListener 'touchmove', @, false
    addEventListener 'touchend', @, false
    addEventListener 'touchcancel', @, false
    @dispatchEvent 'start', originalEvent: e

  _onMove: (e) ->
    @dispatchEvent 'move', originalEvent: e

  _onRelease: (e) ->
    removeEventListener 'mousemove', @, false
    removeEventListener 'mouseup', @, false
    removeEventListener 'touchmove', @, false
    removeEventListener 'touchend', @, false
    removeEventListener 'touchcancel', @, false
    @_startEvent = null
    @dispatchEvent 'release', originalEvent: e

  handleEvent: (e) ->
    unless @disabled
      if e.currentTarget is window
        switch e.type
          when 'mousemove', 'touchmove'
            @_onMove e
          when 'mouseup', 'touchend', 'touchcancel'
            @_onRelease e

      else
        type = e.type
        if e.detail?.originalEvent
          e = e.detail.originalEvent
          moveTarget = @_startEvent.target ? @_startEvent.srcElement

        if type of @_eventListeners
          for handler in @_eventListeners[type]
            @applyHandler handler, [e]

        if type of @_delegatedListeners
          for selector, handlers of @_delegatedListeners[type]
            match = null
            target = moveTarget ? e.target ? e.srcElement
            while target? and not match?
              match = target if matchesSelector target, selector
              target = target.parentNode
            if match?
              for handler in handlers
                @applyHandler handler, [e]

  removeEvent: (eventName, [delegate]..., handler) ->
    # TODO: Allow more general event removal.
    handlers = if delegate?
      if eventName of @_delegatedListeners
        if delegate of @_delegatedListeners[eventName]
          if handler in @_delegatedListeners[eventName]
            @_delegatedListeners[eventName]
    else
      if eventName of @_eventListeners
        if handler in @_eventListeners[eventName]
          @_eventListeners[eventName]

    if handlers?
      index = handlers.indexOf handler
      handlers.splice index, 1

  dispatchEvent: (eventName, detail) ->
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

  trigger: (eventName, args = [])->
    super
    @dispatchEvent eventName, [@, args...]

  pointerOffset: (e) ->
    e = e.touches[0] if 'touches' of e
    {left, top} = @el.getBoundingClientRect()
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top
    {x, y}

  toFront: ->
    @el.parentNode?.appendChild @el

  remove: ->
    @el.parentNode?.removeChild @el

  destroy: ->
    super
    @remove()
    for eventName of @_eventListeners
      @el.removeEventListener eventName, @, false
    for eventName of @_delegatedListeners
      continue if eventName of @_eventListeners
      @el.removeEventListener eventName, @, false
    @_eventListeners = {}
    @_delegatedListeners = {}
