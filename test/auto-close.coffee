TIME_UNTIL_AUTO_CLOSE = 5000

if !!~location.pathname.indexOf '__testling'
  setTimeout close, TIME_UNTIL_AUTO_CLOSE
