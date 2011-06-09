Game = require 'game'
MoveList = require 'move_list'
{square} = require 'square'
{max_value} = require 'square'
{square_sides} = require 'square'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(2)
    @m = @game.moves
    done()

  list_2: (test) ->
    test.equal '0#top, 0#left, 0#bottom, 0#right, 1#top, 1#left, 1#bottom, 1#right', @m.print_list()
    test.done()

  list_3: (test) ->
    @game = new Game(3)
    @m = @game.moves
    test.equal '1#top, 1#left, 1#bottom, 1#right, 0#top, 0#left, 0#bottom, 0#right, 2#top, 2#left, 2#bottom, 2#right', @m.print_list()
    test.done()

  list_5: (test) ->
    @game = new Game(5)
    @m = @game.moves
    test.equal '2#top, 2#left, 2#bottom, 2#right, 1#top, 1#left, 1#bottom, 1#right, 3#top, 3#left, 3#bottom, 3#right, 0#top, 0#left, 0#bottom, 0#right, 4#top, 4#left, 4#bottom, 4#right', @m.print_list()
    test.done()