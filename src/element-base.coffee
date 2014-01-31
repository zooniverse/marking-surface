class ElementBase extends BaseClass
  tagName: 'div'
  className: ''

  constructor: ->
    @_eventListeners = []
    super

    @el ?= document.createElement @tagName
    @toggleClass @constructor::className, true
    @toggleClass @className, true unless @className is @constructor::className

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

  attr: (attribute, value) ->
    if arguments.length is 1
      @el.getAttribute attribute
    else
      if value?
        @el.setAttribute attribute, value
      else
        @el.removeAttribute attribute

  enable: (e) ->
    @attr 'disabled', null
    @disabled = false

  disable: (e) ->
    @attr 'disabled', true
    @disabled = true

  addEvent: (eventName, handler) ->
    @el.addEventListener eventName, handler, false
    eventList = [eventName, handler]
    @_eventListeners.push eventList
    eventList

  removeEvent: (eventName, handler) ->
    for [listedEventName, listedHandler], i in @_eventListeners
      if listedEventName is eventName and listedHandler is handler
        indexInList = i
        break

    @el.removeEventListener eventName, handler
    @_eventListeners.splice indexInList, 1

  triggerEvent: (eventName, detail) ->
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

  trigger: ->
    super
    @triggerEvent arguments...

  pointerOffset: (e) ->
    e = e.touches[0] if 'touches' of e

    {left, top} = @el.getClientRects()[0]
    x = e.pageX - pageXOffset - left
    y = e.pageY - pageYOffset - top

    {x, y}

  destroy: ->
    @removeEvent @_eventListeners[0]... until @_eventListeners.length is 0
    super
