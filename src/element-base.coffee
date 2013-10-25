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

  removeEvent: (eventName, handler) ->
    @el.removeEventListener eventName, handler

  destroy: ->
    @removeEvent @_eventListeners.pop()... until @_eventListeners.length is 0
    super

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

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    {left, top} = @el.getBoundingClientRect()
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top

    {x, y}
