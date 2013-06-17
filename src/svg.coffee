SVG_NS = 'http://www.w3.org/2000/svg'

class SVG
  el: null

  constructor: (tagName, attributes) ->
    [tagName, attributes] = ['svg', tagName] unless typeof tagName is 'string'

    @el = document.createElementNS SVG_NS, tagName
    @attr attributes

  attr: (attribute, value) ->
    if typeof attribute is 'string'
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

  remove: ->
    @el.parentNode.removeChild @el
    null

module.exports = SVG
