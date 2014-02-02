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

class SVG extends ElementBase
  tag: 'svg'
  defaultAttrs: null

  constructor: ->
    super
    if @defaultAttrs?
      @attr @defaultAttrs
      @defaultAttrs = null

  _createEl: ->
    # Classes can be assigned at creation: "circle.foo.bar".
    [tagName, classNames...] = @tag.split '.'
    tagName ||= 'svg'
    [namespace..., tagName] = tagName.split ':'
    namespace = namespace.join(':') || 'svg'
    @el = document.createElementNS NAMESPACES[namespace] || null, tagName
    @attr 'class', classNames.join ' '

  attr: (attribute, value) ->
    if typeof attribute is 'string'
      # Hyphenate camel-cased keys, unless they're case sensitive.
      unless attribute in CASE_SENSITIVE_ATTRIBUTES or attribute in NON_ATTRIBUTE_PROPERTIES
        attribute = (attribute.replace /([A-Z])/g, '-$1').toLowerCase()

      [namespace..., attribute] = attribute.split ':'
      namespace = NAMESPACES[namespace.join ''] ? null

      if arguments.length is 1
        if attribute in NON_ATTRIBUTE_PROPERTIES
          @el[attribute]
        else
          @el.getAttributeNS namespace, attribute
      else
        if value?
          if attribute in NON_ATTRIBUTE_PROPERTIES
            @el[attribute] = value
          else
            @el.setAttributeNS namespace, attribute, value
        else
          @el.removeAttributeNS namespace, attribute

    else
      attributes = attribute
      @attr attribute, value for attribute, value of attributes

  addShape: (tag, defaultAttrs) ->
    # Added shapes are automatically added as children, useful for SVG roots and groups.
    shape = new SVG {tag, defaultAttrs}
    @el.appendChild shape.el
    shape

  filter: (name) ->
    @attr 'filter', if name?
      "url(##{FILTER_ID_PREFIX}#{name})"
    else
      ''

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

focusFilter = SVG.filterDefs.addShape 'filter', id: "#{FILTER_ID_PREFIX}focus"
focusFilter.addShape 'feGaussianBlur', stdDeviation: 3
focusMerge = focusFilter.addShape 'feMerge'
focusMerge.addShape 'feMergeNode'
focusMerge.addShape 'feMergeNode', in: 'SourceGraphic'

# NOTE: The "invert" filter won't work in IE<10.
invertFilter = SVG.filterDefs.addShape 'filter', id: "#{FILTER_ID_PREFIX}invert", colorInterpolationFilters: 'sRGB'
invertTransfer = invertFilter.addShape 'feComponentTransfer'
invertTransfer.addShape 'feFuncR', type: 'table', tableValues: '1 0'
invertTransfer.addShape 'feFuncG', type: 'table', tableValues: '1 0'
invertTransfer.addShape 'feFuncB', type: 'table', tableValues: '1 0'

document.body.appendChild SVG.filtersContainer.el
