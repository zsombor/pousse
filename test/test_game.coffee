Game = require 'game'
{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'

{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(5)
    done()

  starting_board: (test) ->
    test.equal 5, @game.n
    test.equal 25, @game.nn
    test.equal ".....\n.....\n.....\n.....\n....." , @game.print_board()
    test.equal square.black, @game.current_player
    test.notEqual 0, @game.zobrist_a
    test.notEqual 0, @game.zobrist_b
    test.done()

  move_changes_sides: (test) ->
    test.equal square.black, @game.current_player
    @game.move(square_sides.top, 2)
    test.equal square.white, @game.current_player
    test.done()

  move_changes_zobrist_stamps: (test) ->
    original_zobrist_a = @game.zobrist_a
    original_zobrist_b = @game.zobrist_b
    @game.move(square_sides.top, 2)
    test.notEqual original_zobrist_a, @game.zobrist_a
    test.notEqual original_zobrist_b, @game.zobrist_b
    test.done()

  push_down_on_center_column: (test) ->
    @game.move(square_sides.top, 2)
    test.equal "..X..\n.....\n.....\n.....\n.....", @game.print_board()
    test.done()

  push_up_on_center_column: (test) ->
    @game.move(square_sides.bottom, 2)
    test.equal ".....\n.....\n.....\n.....\n..X..", @game.print_board()
    test.done()

  push_left_on_center_column: (test) ->
    @game.move(square_sides.left, 2)
    test.equal ".....\n.....\nX....\n.....\n.....", @game.print_board()
    test.done()

  push_left_twice_on_center_column: (test) ->
    @game.move(square_sides.left, 2)
    @game.move(square_sides.left, 2)
    test.equal ".....\n.....\nOX...\n.....\n.....", @game.print_board()
    test.done()

  push_right_on_center_column: (test) ->
    @game.move(square_sides.right, 2)
    test.equal ".....\n.....\n....X\n.....\n.....", @game.print_board()
    test.done()

  push_right_twice_on_center_column: (test) ->
    @game.move(square_sides.right, 2)
    @game.move(square_sides.right, 2)
    test.equal ".....\n.....\n...XO\n.....\n.....", @game.print_board()
    test.done()

  empty_squares_are_not_pushed: (test) ->
    @game.move(square_sides.right, 2)
    test.equal ".....\n.....\n....X\n.....\n.....", @game.print_board()
    @game.move(square_sides.left, 2)
    test.equal ".....\n.....\nO...X\n.....\n.....", @game.print_board()
    @game.move(square_sides.right, 2)
    test.equal ".....\n.....\nO..XX\n.....\n.....", @game.print_board()
    @game.move(square_sides.left, 2)
    test.equal ".....\n.....\nOO.XX\n.....\n.....", @game.print_board()
    @game.move(square_sides.bottom, 0)
    test.equal ".....\n.....\nOO.XX\n.....\nX....", @game.print_board()
    @game.move(square_sides.top, 0)
    test.equal "O....\n.....\nOO.XX\n.....\nX....", @game.print_board()
    test.done()

  push_down_on_center_column_six_times: (test) ->
    test.equal ".....\n.....\n.....\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n.....\n.....\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..O..\n..X..\n.....\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n..O..\n..X..\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..O..\n..X..\n..O..\n..X..\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n..O..\n..X..\n..O..\n..X..", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..O..\n..X..\n..O..\n..X..\n..O..", @game.print_board()
    test.done()

  repeat_left_and_down_pushes_on_center_column_and_row: (test) ->
    test.equal ".....\n.....\n.....\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n.....\n.....\n.....\n.....", @game.print_board()
    @game.move(square_sides.left, 2)
    test.equal "..X..\n.....\nO....\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n..X..\nO....\n.....\n.....", @game.print_board()
    @game.move(square_sides.left, 2)
    test.equal "..X..\n..X..\nOO...\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n..X..\nOOX..\n.....\n.....", @game.print_board()
    @game.move(square_sides.left, 2)
    test.equal "..X..\n..X..\nOOOX.\n.....\n.....", @game.print_board()
    @game.move(square_sides.top, 2)
    test.equal "..X..\n..X..\nOOXX.\n..O..\n.....", @game.print_board()
    test.done()

  alpha_beta_depth_1: (test) ->
    @game = new Game(5)
    #console.log @game.alpha_beta(-max_value, max_value, 40)
    test.done()

