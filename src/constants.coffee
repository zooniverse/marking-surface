$ = window.jQuery
Raphael = window.Raphael

doc = $(document)

# Disable touch temporarily for new Chrome.
TOUCH = false # 'Touch' of window
[START, MOVE, END] = if TOUCH
  ['touchstart', 'touchmove', 'touchend']
else
  ['mousedown', 'mousemove', 'mouseup']

BACKSPACE = 8
DELETE = 46
TAB = 9
