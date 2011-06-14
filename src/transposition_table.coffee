TranspositionTableEntry = require 'transposition_table_entry'
{square} = require 'square'

module.exports = class TranspositionTable
  constructor: (@game, @log_size = 15) ->
    @size = Math.pow(2, @log_size)
    @table = new Array(@size)
    @current_search_id = 0
    i = 0
    while i < @size
      @table[i] = new TranspositionTableEntry(square.empty, 0, 0, 0, 0, 0, 0, 0)
      i += 1
    @xor_table_a = new Array(@game.nn * 3)
    @xor_table_b = new Array(@game.nn * 3)
    @xor_table_c = new Array(@game.nn * 3)
    i = 0
    max_positive_integer = 256*256*256*64
    while i < @game.nn * 3
      @xor_table_a[i] = Math.floor(Math.random() * max_positive_integer)
      @xor_table_b[i] = Math.floor(Math.random() * max_positive_integer)
      @xor_table_c[i] = Math.floor(Math.random() * max_positive_integer)
      i += 1
    this.reset_zobrist_stamp_for_game()

  bump_search_id: () ->
    @current_search_id += 1

  hash:() ->
    @game.zobrist_a >> (32-@log_size)

  retrieve: () ->
    ndx = this.hash()
    hit = @table[ndx]
    if @game.zobrist_b != hit.zobrist_b or @game.zobrist_c != hit.zobrist_c or @game.current_player != hit.player
      null
    else
      hit

  store: (values) ->
    ndx = this.hash()
    if values.depth >= @table[ndx].depth or @table[ndx].search_id != @current_search_id
      @table[ndx].zobrist_b = @game.zobrist_b
      @table[ndx].zobrist_c = @game.zobrist_c
      @table[ndx].player = @game.current_player
      @table[ndx].depth = values.depth
      @table[ndx].position_value = values.position_value
      @table[ndx].position_value_type = values.position_value_type
      @table[ndx].best_move = values.best_move

  update_zobrist_stamp_for_square_change: (pos, changed_to) ->
    from = pos + (@game.table[pos] + 1)
    to = pos + (changed_to + 1)
    @game.zobrist_a ^= @xor_table_a[from] ^ @xor_table_a[to]
    @game.zobrist_b ^= @xor_table_b[from] ^ @xor_table_b[to]
    @game.zobrist_c ^= @xor_table_c[from] ^ @xor_table_c[to]
    true


  reset_zobrist_stamp_for_game: () ->
    @game.zobrist_a = 0
    @game.zobrist_b = 0
    @game.zobrist_c = 0
    i = 0
    while i < @game.nn
      ndx = i + (@game.table[i] + 1)
      @game.zobrist_a ^=  @xor_table_a[ ndx ]
      @game.zobrist_b ^=  @xor_table_b[ ndx ]
      @game.zobrist_c ^=  @xor_table_c[ ndx ]
      i += 1
