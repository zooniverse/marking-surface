matchesSelector = do ->
  MATCH_METHODS = [
    'mozMatchesSelector'
    'msMatchesSelector'
    'oMatchesSelector'
    'webkitMatchesSelector'
    'matchesSelector'
    'matches'
  ]

  MATCHES_SELECTOR = method for method in MATCH_METHODS when method of Element::

  (el, selector) -> el[MATCHES_SELECTOR]? selector

insertStyle = do ->
  IE_HACK_ID = 'marking-surface-element-that-only-exists-to-please-ie'

  (id, styleContent) ->
    document.querySelector('style, link[rel="stylesheet"]').insertAdjacentHTML 'beforeBegin', """
      <span id="#{IE_HACK_ID}"></span>
      <style id="#{id}">#{styleContent}</style>
    """

    ieHackElement = document.getElementById IE_HACK_ID
    ieHackElement.parentNode.removeChild ieHackElement

    document.getElementById id
