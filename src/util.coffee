removeFrom = (item, array) ->
  array.splice (array.indexOf item), 1 until item not in array
  null

toggleClass = (element, className, condition) ->
  classList = element.className.match /\S+/g
  classList ?= []

  contained = className in classList

  condition ?= !contained
  condition = !!condition

  if not contained and condition is true
    classList.push className

  if contained and condition is false
    removeFrom className, classList

  element.className = classList.join ' '
  null
