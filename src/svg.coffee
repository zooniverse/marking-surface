SVG_NS = 'http://www.w3.org/2000/svg'

CASE_SENSITIVE_ATTRIBUTES = ['viewBox']

NAMESPACES =
  xlink: 'http://www.w3.org/1999/xlink'

FILTERS =
  shadow: 'marking-surface-shadow'

class SVG
  el: null

  constructor: (tagName, attributes) ->
    # Without a tag name, create an SVG container.
    [tagName, attributes] = ['svg', tagName] unless typeof tagName is 'string'

    # Classes can be assigned at creation: "circle.foo.bar".
    [tagName, classes...] = tagName.split '.'
    classes = classes.join ' '

    @el = document.createElementNS SVG_NS, tagName

    @attr 'class', classes if classes
    @attr attributes

  attr: (attribute, value) ->
    # Given a key and a value:
    if typeof attribute is 'string'
      # Hyphenate camel-cased keys, unless they're case sensitive.
      unless attribute in CASE_SENSITIVE_ATTRIBUTES
        attribute = (attribute.replace /([A-Z])/g, '-$1').toLowerCase()

      [namespace..., attribute] = attribute.split ':'
      namespace = NAMESPACES[namespace[0]] || null

      @el.setAttributeNS namespace, attribute, value

    # Given an object:
    else
      attributes = attribute
      @attr attribute, value for attribute, value of attributes

    null

  filter: (filter) ->
    @attr 'filter', if filter?
      "url(##{FILTERS[filter]})"
    else
      ''

  addShape: (tagName, attributes) ->
    # Added shapes are automatically added as children, useful for SVG roots and groups.
    shape = new @constructor tagName, attributes
    @el.appendChild shape.el
    shape

  toFront: ->
    @el.parentNode.appendChild @el
    null

  remove: ->
    @el.parentNode.removeChild @el
    null

FILTERS_CONTAINER = new SVG
  id: 'marking-surface-filters-container'
  width: 0
  height: 0
  style: 'bottom: 0; position: absolute; right: 0;'

defs = FILTERS_CONTAINER.addShape 'defs'

shadow = defs.addShape 'filter', id: FILTERS.shadow
shadow.addShape 'feOffset', in: 'SourceAlpha', dx: '1', dy: '2', result: 'offOut'
shadow.addShape 'feBlend', in: 'SourceGraphic', in2: 'offOut'

document.body.appendChild FILTERS_CONTAINER.el
