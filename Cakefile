# -*- Mode:coffee; -*-

{exec} = require 'child_process'

run = (command, callback) ->
  exec command, (err, stdout, stderr) ->
    console.warn stderr if stderr
    callback?() unless err

build = (callback) ->
  run 'coffee -co lib src', callback

build_tests = (callback) ->
  run 'coffee -co test test', callback

task "build", "Build lib/ from src/", ->
  build()

task "build_tests", "Build tests", ->
  build_tests()

require.paths.unshift __dirname + '/lib'

task "test", "Run tests", ->
  build ->
    build_tests ->
      {reporters} = require 'nodeunit'
      reporters.default.run ['test']

task "play", "Play the game", ->
  build ->
    Game = require 'game'
    g = new Game(5)
    g.play()