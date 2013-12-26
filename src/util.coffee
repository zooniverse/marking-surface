IE_HACK_ID = 'marking-surface-element-that-only-exists-to-please-ie'

insertStyle = (id, styleContent) ->
  document.querySelector('style, link[rel="stylesheet"]').insertAdjacentHTML 'beforeBegin', """
    <span id="#{IE_HACK_ID}"></span>
    <style id="#{id}">#{styleContent}</style>
  """

  ieHackElement = document.getElementById IE_HACK_ID
  ieHackElement.parentNode.removeChild ieHackElement

  document.getElementById id
