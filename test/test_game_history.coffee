Game = require 'game'
{square_sides} = require 'square'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(2)
    @h = @game.history
    done()

  loop_detection: (test) ->
    test.equal false, @h.loop_encountered
    @game.move(square_sides.right, 0)
    test.equal ".X\n..", @game.print_board()
    test.equal false, @h.loop_encountered
    @game.move(square_sides.right, 0)
    test.equal "XO\n..", @game.print_board()
    test.equal false, @h.loop_encountered
    @game.move(square_sides.right, 0)
    test.equal "OX\n..", @game.print_board()
    test.equal false, @h.loop_encountered
    @game.move(square_sides.right, 0)
    test.equal "XO\n..", @game.print_board()
    test.equal true, @h.loop_encountered
    test.done()
