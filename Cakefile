{spawn} = require 'child_process'

DEFAULT_PORT = 4567

run = ->
  child = spawn arguments...
  child.stdout.on 'data', process.stdout.write.bind process.stdout
  child.stderr.on 'data', process.stderr.write.bind process.stderr


task 'watch', 'Watch changes during development', ->
  run 'coffee', ['--watch', '--output', './lib', '--compile', './src']

option '-p', '--port [PORT]', 'Port on which to run the dev server'

task 'serve', 'Run a dev server', (options) ->
  invoke 'watch'
  run 'silver', ['server', '--port', options.port || process.env.PORT || DEFAULT_PORT]
