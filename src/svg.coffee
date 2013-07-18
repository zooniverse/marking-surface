SVG_NS = 'http://www.w3.org/2000/svg'

CASED_ATTRIBUTES = ['viewBox']

class SVG
  el: null

  constructor: (tagName, attributes) ->
    [tagName, attributes] = ['svg', tagName] unless typeof tagName is 'string'

    [tagName, classes...] = tagName.split '.'

    @el = document.createElementNS SVG_NS, tagName
    @el.classList.add className for className in classes
    @attr attributes

  attr: (attribute, value) ->
    if typeof attribute is 'string'
      unless attribute in CASED_ATTRIBUTES
        attribute = (attribute.replace /([A-Z])/g, '-$1').toLowerCase()

      @el.setAttributeNS null, attribute, value
    else
      attributes = attribute
      @attr attribute, value for attribute, value of attributes
    null

  addShape: (tagName, attributes) ->
    shape = new @constructor tagName, attributes
    @el.appendChild shape.el
    shape

  toFront: ->
    @el.parentNode.appendChild @el
    null

  remove: ->
    @el.parentNode.removeChild @el
    null
