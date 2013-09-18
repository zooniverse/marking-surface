exec = require 'easy-exec'

DEFAULT_PORT = 4567

sources = '''
  src/util.coffee
  src/base-class.coffee
  src/svg.coffee
  src/mark.coffee
  src/tool-controls.coffee
  src/tool.coffee
  src/marking-surface.coffee
  src/exports.coffee
'''

task 'serve', 'Run a dev server', ->
  exec "coffee --watch --map --join ./lib/marking-surface.js --compile #{sources}"
  exec 'coffee --watch --output ./lib/tools --compile ./src/tools'
  exec "silver server --port #{process.env.PORT || DEFAULT_PORT}"
