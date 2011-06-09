TranspositionTableEntry = require 'transposition_table_entry'
{square} = require 'square'

module.exports = class TranspositionTable
  constructor: (@game, @log_size = 15) ->
    @size = Math.pow(2, @log_size)
    @table = new Array(@size)
    i = 0
    while i < @size
      @table[i] = new TranspositionTableEntry(square.empty, 0, 0, 0, 0, 0)
      i += 1
    @xor_table_a = new Array(@game.nn * 3)
    @xor_table_b = new Array(@game.nn * 3)
    i = 0
    max_positive_integer = 256*256*256*64
    while i < @game.nn * 3
      @xor_table_a[i] = Math.floor(Math.random() * max_positive_integer)
      @xor_table_b[i] = Math.floor(Math.random() * max_positive_integer)
      i += 1
    this.reset_zobrist_stamp_for_game()

  hash:() ->
    @game.zobrist_a >> (32-@log_size)

  retrieve: () ->
    ndx = this.hash()
    if @game.table[ndx].zobrist != @table[ndx].zobrist_b or @game.current_player != @table[ndx].player
      null
    else
      @table[ndx]

  store: (values) ->
    ndx = this.hash()
    if (values.depth > @table[ndx].depth) # or (@game.table[ndx].zobrist == @table[ndx].zobrist_b and @game.current_player == @table[ndx].player)
      @table[ndx].zobrist = @game.zobrist_b
      @table[ndx].player = @game.current_player
      @table[ndx].depth = values.depth
      @table[ndx].position_value = values.position_value
      @table[ndx].position_value_type = values.position_value_type
      @table[ndx].best_move = values.best_move

  update_zobrist_stamp_for_square_change: (pos, changed_to) ->
    @game.zobrist_a ^= @xor_table_a[pos + (@game.table[pos] + 1)] ^ @xor_table_a[pos + (changed_to + 1)]
    @game.zobrist_b ^= @xor_table_b[pos + (@game.table[pos] + 1)] ^ @xor_table_b[pos + (changed_to + 1)]

  reset_zobrist_stamp_for_game: () ->
    @game.zobrist_a = 0
    @game.zobrist_b = 0
    i = 0
    while i < @game.nn
      @game.zobrist_a ^=  @xor_table_a[ i + (@game.table[i] + 1) ]
      @game.zobrist_b ^=  @xor_table_b[ i + (@game.table[i] + 1) ]
      i += 1
