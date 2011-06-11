Undo = require 'undo'
Game = require 'game'
Evaluator = require 'evaluator'
{square} = require 'square'

{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(5)
    @evaluator = @game.evaluator
    @undo = new Undo(@evaluator, @game)
    done()

  top_ndx_is_zero: (test) ->
    test.equal 0, @undo.top_ndx
    test.done()

  piece_balance_is_restored: (test) ->
    i = 0
    while i < @game.n
      @evaluator.piece_balance_per_row[i] = 3
      @evaluator.piece_balance_per_column[i] = -3
      i += 1
    @undo.mark()
    i = 0
    while i < @game.n
      @evaluator.piece_balance_per_row[i] = 5
      @evaluator.piece_balance_per_column[i] = -5
      i += 1
    @undo.restore_last_mark()
    i = 0
    while i < @game.n
      test.equal 3, @evaluator.piece_balance_per_row[i]
      test.equal -3, @evaluator.piece_balance_per_column[i]
      i += 1
    test.equal 0, @undo.top_ndx
    test.done()

  zobrist_stamps_are_restored: (test) ->
    @game.zobrist_a = 354523
    @game.zobrist_b = 897897
    @undo.mark()
    @game.zobrist_a = 'something else'
    @game.zobrist_b = 'that should not persist'
    @undo.restore_last_mark()
    test.equal 897897, @game.zobrist_b
    test.equal 354523, @game.zobrist_a
    test.done()

  game_current_player_is_restored: (test) ->
    @game.current_player = square.black
    @undo.mark()
    @game.current_player = square.white
    @undo.restore_last_mark()
    test.equal square.black, @game.current_player
    test.done()

  game_over_on_evaluator_is_reset_to_false: (test) ->
    @game.evaluator.game_over = false
    @undo.mark()
    @game.evaluator.game_over = true
    @undo.restore_last_mark()
    test.equal false, @game.evaluator.game_over
    test.done()

  manhattan_balance_is_restored: (test) ->
    @game.evaluator.manhattan_balance = 55
    @undo.mark()
    @game.evaluator.manhattan_balance = 77
    @undo.restore_last_mark()
    test.equal 55, @game.evaluator.manhattan_balance
    test.done()


  game_table_is_restored: (test) ->
    board = @game.print_board()
    @undo.mark()
    i = 0
    while i < @game.nn
      @game.table[i] = square.black
      i += 1
    test.notEqual board, @game.print_board()
    test.equal "XXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX", @game.print_board()
    @undo.restore_last_mark()
    test.equal board, @game.print_board()
    test.done()