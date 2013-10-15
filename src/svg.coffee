NAMESPACES =
  svg: 'http://www.w3.org/2000/svg'
  xlink: 'http://www.w3.org/1999/xlink'

CASE_SENSITIVE_ATTRIBUTES = [
  'viewBox'
  'preserveAspectRatio'
]

NON_ATTRIBUTE_PROPERTIES = [
  'textContent'
]

filters =
  shadow: [
    {element: 'feOffset', attributes: {in: 'SourceAlpha', dx: 0.5, dy: 1.5, result: 'offOut'}}
    {element: 'feBlend', attributes: {in: 'SourceGraphic', in2: 'offOut'}}
  ]

class SVG
  el: null

  constructor: (tagName, attributes) ->
    # Without a tag name, create an SVG container.
    [tagName, attributes] = ['svg', tagName] unless typeof tagName is 'string'

    # Classes can be assigned at creation: "circle.foo.bar".
    [tagName, classes...] = tagName.split '.'
    classes = classes.join ' '

    [namespace..., tagName] = tagName.split ':'
    namespace = namespace.join ''
    namespace ||= 'svg'

    @el = document.createElementNS NAMESPACES[namespace] || null, tagName

    @attr 'class', classes if classes
    @attr attributes

  attr: (attribute, value) ->
    if typeof attribute is 'string'
      # Hyphenate camel-cased keys, unless they're case sensitive.
      unless attribute in CASE_SENSITIVE_ATTRIBUTES or attribute in NON_ATTRIBUTE_PROPERTIES
        attribute = (attribute.replace /([A-Z])/g, '-$1').toLowerCase()

      [namespace..., attribute] = attribute.split ':'
      namespace = namespace.join ''

      if value? # Setter
        if attribute in NON_ATTRIBUTE_PROPERTIES
          @el[attribute] = value
        else
          @el.setAttributeNS NAMESPACES[namespace] || null, attribute, value

      else # Getter
        return if attribute in NON_ATTRIBUTE_PROPERTIES
          @el[attribute]
        else
          @el.getAttributeNS NAMESPACES[namespace] || null, attribute

    else # Given an object to loop through:
      attributes = attribute
      @attr attribute, value for attribute, value of attributes

    null

  filter: (name) ->
    @attr 'filter', if name?
      "url(#marking-surface-filter-#{name})"
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

SVG.filtersContainer = new SVG
  id: 'marking-surface-filters-container'
  width: 0
  height: 0
  style: 'bottom: 0; position: absolute; right: 0;'

defs = SVG.filtersContainer.addShape 'defs'

SVG.registerFilter = (name, elements) ->
  filters[name] = elements
  filter = defs.addShape 'filter', id: "marking-surface-filter-#{name}"
  filter.addShape element, attributes for {element, attributes} in elements
  null

SVG.registerFilter name, elements for name, elements of filters

document.body.appendChild SVG.filtersContainer.el
