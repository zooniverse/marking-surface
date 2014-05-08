NAMESPACES =
  svg: 'http://www.w3.org/2000/svg'
  xlink: 'http://www.w3.org/1999/xlink'

CASE_SENSITIVE_ATTRIBUTES = [
  'markerHeight'
  'markerWidth'
  'preserveAspectRatio'
  'refX'
  'refY'
  'stdDeviation'
  'tableValues',
  'viewBox'
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
    @on 'marking-surface:base:destroy', [shape, 'destroy']
    @el.appendChild shape.el
    shape

  filter: (name) ->
    @attr 'filter', if name?
      "url(##{FILTER_ID_PREFIX}#{name})"
    else
      ''

document.body.insertAdjacentHTML 'afterBegin', """
  <svg id="marking-surface-filters-container" width="0" height="0" style="bottom: 0; position: absolute; right: 0;">
    <defs>
      <filter id="#{FILTER_ID_PREFIX}shadow">
        <feGaussianBlur stdDeviation="2" in="SourceAlpha" />
        <feOffset dx="0.5" dy="1" />
        <feMerge>
          <feMergeNode />
          <feMergeNode in="SourceGraphic" />
        </feMerge>
      </filter>

      <filter id="#{FILTER_ID_PREFIX}focus">
        <feGaussianBlur stdDeviation="3" />
        <feMerge>
          <feMergeNode />
          <feMergeNode in="SourceGraphic" />
        </feMerge>
      </filter>

      <filter id="#{FILTER_ID_PREFIX}invert" color-interpolation-filters="sRGB">
        <feComponentTransfer>
          <feFuncR type="table" tableValues="1 0" />
          <feFuncG type="table" tableValues="1 0" />
          <feFuncB type="table" tableValues="1 0" />
        </feComponentTransfer>
      </filter>
    </defs>
  </svg>
"""
