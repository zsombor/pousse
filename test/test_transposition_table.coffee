Game = require 'game'
TranspositionTable = require 'transposition_table'
{square} = require 'square'
{square_sides} = require 'square'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @game = new Game(3)
    @tt = @game.transposition_table
    done()

  transposition_table: (test) ->
    test.equal Math.pow(2, @tt.log_size), @tt.table.length
    for entry in @tt.table
      test.equal square.empty, entry.player
      test.equal 0, entry.depth
      test.equal 0, entry.position_value
      test.equal 0, entry.position_value_type
      test.equal 0, entry.best_move
      test.equal 0, entry.zobrist_b
      test.equal 0, entry.zobrist_c
    test.done()

  the_hash_fits_within_the_table: (test) ->
    @game.zobrist_a =  256*256*256*64
    @tt.log_size = 10
    test.equal 256, @tt.hash()
    @tt.log_size = 5
    test.equal 8, @tt.hash()
    @tt.log_size = 3
    test.equal 2, @tt.hash()
    @tt.log_size = 2
    test.equal 1, @tt.hash()
    test.done()

  xor_table_size: (test) ->
    test.equal 27, @tt.xor_table_a.length
    test.equal 27, @tt.xor_table_b.length
    test.done()

  xor_table_all_different_values: (test) ->
    xor_values = @tt.xor_table_a.concat @tt.xor_table_b
    for value, i in xor_values
      test.equal i, xor_values.indexOf(value)
      test.equal i, xor_values.lastIndexOf(value)
    test.done()

  retrieve_returns_null_when_zobrist_hash_does_not_match: (test) ->
    test.equal null, @tt.retrieve()
    test.notEqual 3333, @game.zobrist_b
    @tt.table[@tt.hash()].zobrist_b = 3333
    @game.zobrist_b = 3333
    test.notEqual 7777, @game.zobrist_c
    @tt.table[@tt.hash()].zobrist_c = 7777
    test.equal null, @tt.retrieve()
    test.done()

  retrieve_returns_null_when_zobrist_hash_matches_but_players_do_not: (test) ->
    @tt.table[@tt.hash()].zobrist_b = 3333
    @game.zobrist_b = 3333
    @tt.table[@tt.hash()].zobrist_c = 4444
    @game.zobrist_c = 444
    @tt.table[@tt.hash()].player = square.black
    @game.current_player = square.white
    test.equal null, @tt.retrieve()
    test.done()

  retrieve_match: (test) ->
    @tt.table[@tt.hash()].zobrist_b = 3333
    @game.zobrist_b = 3333
    @tt.table[@tt.hash()].zobrist_c = 1111
    @game.zobrist_c = 1111
    @tt.table[@tt.hash()].player = square.black
    @game.current_player = square.black
    test.notEqual null, @tt.retrieve()
    test.equal @tt.table[@tt.hash()], @tt.retrieve()
    test.done()

  stores_can_be_retrieved: (test) ->
    test.equal null, @tt.retrieve()
    @tt.store({depth: 3, position_value_type: 1, position_value: 4, best_move: 7})
    res = @tt.retrieve()
    test.notEqual null, res
    test.equal @game.current_player, res.player
    test.equal 3, res.depth
    test.equal 4, res.position_value
    test.equal 1, res.position_value_type
    test.equal 7, res.best_move
    test.done()

  incremental_updates_on_zobrist_keys: (test) ->
    a = @game.zobrist_a
    b = @game.zobrist_b
    @game.move(square_sides.top, 2)
    @game.move(square_sides.top, 2)
    @game.move(square_sides.top, 2)
    @game.move(square_sides.top, 1)
    @game.move(square_sides.top, 1)
    @game.move(square_sides.top, 1)
    test.notEqual a, @game.zobrist_a
    test.notEqual b, @game.zobrist_b
    a = @game.zobrist_a
    b = @game.zobrist_b
    @tt.reset_zobrist_stamp_for_game()
    test.equal a, @game.zobrist_a
    test.equal b, @game.zobrist_b
    test.done()

  incremental_updates_on_zobrist_keys__2: (test) ->
    @game = new Game(2)
    @tt = @game.transposition_table
    @game.move(square_sides.right, 0)
    a = @game.zobrist_a
    b = @game.zobrist_b
    c = @game.zobrist_c
    @game.move(square_sides.right, 0)
    test.notEqual a, @game.zobrist_a
    test.notEqual b, @game.zobrist_b
    test.notEqual c, @game.zobrist_c
    @game.move(square_sides.right, 0)
    test.notEqual a, @game.zobrist_a
    test.notEqual b, @game.zobrist_b
    test.notEqual c, @game.zobrist_c
    a = @game.zobrist_a
    b = @game.zobrist_b
    c = @game.zobrist_c
    @tt.reset_zobrist_stamp_for_game()
    test.equal a, @game.zobrist_a
    test.equal b, @game.zobrist_b
    test.equal c, @game.zobrist_c
    test.done()





