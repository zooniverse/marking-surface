class ElementBase extends BaseClass
  tagName: 'div'
  className: ''
  disabled: false

  constructor: ->
    super
    @_eventListeners = []

    @el = document.querySelector @el if typeof @el is 'string'
    @el ?= document.createElement @tagName
    @toggleClass @constructor::className, true
    @toggleClass @className, true unless @className is @constructor::className

    @disable() if @disabled

  toggleClass: (className, condition) ->
    classList = @el.className.match /\S+/g
    classList ?= []

    contained = className in classList

    condition ?= !contained
    condition = !!condition

    if not contained and condition is true
      classList.push className

    if contained and condition is false
      classList.splice (classList.indexOf className), 1

    @el.className = classList.join ' '
    null

  enable: (e) ->
    @disabled = false
    @el.removeAttribute 'disabled'
    null

  disable: (e) ->
    @disabled = true
    @el.setAttribute 'disabled', 'disabled'
    null

  addEvent: (eventName, handler) ->
    @el.addEventListener eventName, handler, false
    eventList = [eventName, handler]
    @_eventListeners.push eventList
    eventList

  triggerEvent: (eventName, detail) ->
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

  removeEvent: (eventName, handler) ->
    for [listedEventName, listedHandler], i in @_eventListeners
      if listedEventName is eventName and listedHandler is handler
        indexInList = i
        break

    @el.removeEventListener eventName, handler
    @_eventListeners.splice indexInList, 1

  pointerOffset: (e) ->
    e = e.touches[0] if 'touches' of e

    {left, top} = @el.getClientRects()[0]
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top

    {x, y}

  destroy: ->
    @removeEvent @_eventListeners[0]... until @_eventListeners.length is 0
    super
