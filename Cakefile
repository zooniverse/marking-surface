{spawn} = require 'child_process'

DEFAULT_PORT = 4567

run = ->
  child = spawn arguments...
  child.stdout.on 'data', process.stdout.write.bind process.stdout
  child.stderr.on 'data', process.stderr.write.bind process.stderr

sources = [
  'src/constants'
  'src/base-class'
  'src/mark'
  'src/tool-controls'
  'src/tool'
  'src/marking-surface'
  'src/exports'
]

option '-p', '--port [PORT]', 'Port on which to run the dev server'

task 'watch', 'Watch changes during development', ->
  run 'coffee', ['--watch', '--compile', '--join', './lib/marking-surface.js', sources...]

task 'serve', 'Run a dev server', (options) ->
  invoke 'watch'
  run 'silver', ['server', '--port', options.port || process.env.PORT || DEFAULT_PORT]
