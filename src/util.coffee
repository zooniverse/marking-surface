# TODO: Add keyboard support.

# BACKSPACE = 8
# DELETE = 46
# TAB = 9

removeFrom = (item, array) ->
  array.splice i, 1 for thing, i in array by -1 when thing is item
  null

toggleClass = (element, className, condition) ->
  classList = element.className.split /\s+/
  contained = className in classList

  condition ?= !contained
  condition = !!condition

  if not contained and condition is true
    classList.push className

  if contained and condition is false
    removeFrom className, classList

  element.className = classList.join ' '
  null
