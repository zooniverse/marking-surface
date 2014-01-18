NAMESPACES =
  svg: 'http://www.w3.org/2000/svg'
  xlink: 'http://www.w3.org/1999/xlink'

CASE_SENSITIVE_ATTRIBUTES = [
  'viewBox'
  'preserveAspectRatio'
  'stdDeviation'
  'tableValues'
]

NON_ATTRIBUTE_PROPERTIES = [
  'textContent'
]

FILTER_ID_PREFIX = 'marking-surface-filter-'

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

  # Sigh, basically copied and pasted.
  # Can't borrow ElementBase::toggleClass because of "baseVal".
  toggleClass: (className, condition) ->
    classList = @el.className.baseVal.match /\S+/g
    classList ?= []

    contained = className in classList

    condition ?= !contained
    condition = !!condition

    if not contained and condition is true
      classList.push className

    if contained and condition is false
      classList.splice (classList.indexOf className), 1

    @el.className.baseVal = classList.join ' '
    null

  filter: (name) ->
    @attr 'filter', if name?
      "url(##{FILTER_ID_PREFIX}#{name})"
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
    @el.parentNode?.removeChild @el
    null

SVG.filtersContainer = new SVG
  id: 'marking-surface-filters-container'
  width: 0
  height: 0
  style: 'bottom: 0; position: absolute; right: 0;'

SVG.filterDefs = SVG.filtersContainer.addShape 'defs'

shadowFilter = SVG.filterDefs.addShape 'filter', id: "#{FILTER_ID_PREFIX}shadow"
shadowFilter.addShape 'feGaussianBlur', stdDeviation: 2, in: 'SourceAlpha'
shadowFilter.addShape 'feOffset', dx: 0.5, dy: 1
shadowMerge = shadowFilter.addShape 'feMerge'
shadowMerge.addShape 'feMergeNode'
shadowMerge.addShape 'feMergeNode', in: 'SourceGraphic'

# NOTE: The "invert" filter won't work in IE<10.
invertFilter = SVG.filterDefs.addShape 'filter', id: "#{FILTER_ID_PREFIX}invert", colorInterpolationFilters: 'sRGB'
invertTransfer = invertFilter.addShape 'feComponentTransfer'
invertTransfer.addShape 'feFuncR', type: 'table', tableValues: '1 0'
invertTransfer.addShape 'feFuncG', type: 'table', tableValues: '1 0'
invertTransfer.addShape 'feFuncB', type: 'table', tableValues: '1 0'

document.body.appendChild SVG.filtersContainer.el
