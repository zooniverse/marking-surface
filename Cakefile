{spawn} = require 'child_process'

run = ->
  child = spawn arguments...
  child.stdout.on 'data', process.stdout.write.bind process.stdout
  child.stderr.on 'data', process.stderr.write.bind process.stderr

sources = [
  'src/constants.coffee'
  'src/base-class.coffee'
  'src/mark.coffee'
  'src/tool-controls.coffee'
  'src/tool.coffee'
  'src/marking-surface.coffee'
  'src/exports.coffee'
]

option '-p', '--port [PORT]', 'Port on which to run the dev server'

task 'serve', 'Run a dev server', ->
  run 'coffee', ['--watch', '--join', './lib/marking-surface.js', '--compile', sources...]
  run 'coffee', ['--watch', '--output', './lib/tools', '--compile', './src/tools']
  run 'silver', ['server', '--port', process.env.PORT || 4567]
