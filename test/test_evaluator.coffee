Game = require 'game'
Evaluator = require 'evaluator'
{square} = require 'square'
{max_value} = require 'square'
{square_sides} = require 'square'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(5)
    @e = @game.evaluator
    done()

  starting_position: (test) ->
    test.equal "col: 0,0,0,0,0 row: 0,0,0,0,0", @e.print_balances()
    test.done()

  push_down_on_center_column: (test) ->
    @game.move(square_sides.top, 2)
    test.equal "col: 0,0,1,0,0 row: 1,0,0,0,0", @e.print_balances()
    test.equal false, @e.is_game_over()
    test.done()

  push_down_twice_on_center_column: (test) ->
    @game.move(square_sides.top, 2)
    @game.move(square_sides.top, 2)
    test.equal "col: 0,0,0,0,0 row: -1,1,0,0,0", @e.print_balances()
    test.equal false, @e.is_game_over()
    test.done()

  push_down_left_down_left_on_center_column: (test) ->
    @game.move(square_sides.top, 2)
    @game.move(square_sides.left, 2)
    @game.move(square_sides.top, 2)
    @game.move(square_sides.left, 2)
    test.equal 'col: -1,-1,2,0,0 row: 1,1,-2,0,0', @e.print_balances()
    test.equal false, @e.is_game_over()
    test.done()

  game_over_black: (test) ->
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 1)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 2)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 1)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 2)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal true, @e.is_game_over()
    test.equal square.black, @e.winning_player
    test.equal max_value, @e.evaluate()
    test.done()

  game_over_white: (test) ->
    @game.move(square_sides.top, 1)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 1)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 2)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 1)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 2)
    test.equal false, @e.is_game_over()
    @game.move(square_sides.top, 0)
    test.equal true, @e.is_game_over()
    test.equal square.white, @e.winning_player
    test.equal -max_value, @e.evaluate()
    test.done()

  test_is_game_over_b: (test) ->
    @game.move(square_sides.top, 4)
    @game.move(square_sides.top, 3)
    @game.move(square_sides.top, 4)
    @game.move(square_sides.top, 3)
    @game.move(square_sides.left, 3)
    @game.move(square_sides.right, 3)
    @game.move(square_sides.right, 4)
    @game.move(square_sides.right, 2)
    @game.move(square_sides.right, 3)
    @game.move(square_sides.bottom, 3)
    @game.move(square_sides.right, 2)
    test.equal false, @e.is_game_over()
    test.done()


  # game_over_by_shifting_opponents_piece_into_a_line: (test) ->
  #   @game = new Game(3)
  #   @e = @game.evaluator
  #   @game.move(square_sides.left, 0)
  #   test.equal 'X##\n###\n###', @game.print_board()
  #   @game.move(square_sides.left, 1)
  #   test.equal 'X##\nO##\n###', @game.print_board()
  #   @game.move(square_sides.left, 0)
  #   test.equal 'XX#\nO##\n###', @game.print_board()
  #   @game.move(square_sides.left, 1)
  #   test.equal 'XX#\nOO#\n###', @game.print_board()
  #   @game.move(square_sides.bottom, 2)
  #   test.equal 'XX#\nOO#\n##X', @game.print_board()
  #   test.done()

  evaluate: (test) ->
    @game.move(square_sides.top, 0)
    test.equal true, @e.evaluate() > 0
    @game.move(square_sides.top, 0)
    test.equal true, @e.evaluate() > 0
    test.done()

  evaluate_not_nan: (test) ->
    @game = new Game(2)
    @e = @game.evaluator
    @game.move(square_sides.left, 1)
    test.equal false, @e.is_game_over()
    test.notEqual max_value, Math.abs(@e.evaluate())
    @game.move(square_sides.left, 0)
    test.equal false, @e.is_game_over()
    test.notEqual max_value, Math.abs(@e.evaluate())
    @game.move(square_sides.left, 1)
    test.equal true, @e.is_game_over()
    test.equal max_value, @e.evaluate()
    test.done()

  precomputed_manhattan_distance_matrix: (test) ->
    test.equal("0,1,2,1,0,1,2,3,2,1,2,3,4,3,2,1,2,3,2,1,0,1,2,1,0",  @e.manhattan_distances.join(','))
    test.done()

