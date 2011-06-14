

module.exports = class Undo
  constructor: (@evaluator, @game) ->
    @backup = new Array((@game.n * 3 + 2 + 1 + @game.nn) * @game.maximum_search_depth)
    @top_ndx = 0

  mark: () ->
    i = 0
    while i < @game.n
      @backup[@top_ndx + i] = @evaluator.piece_balance_per_row[i]
      i += 1
    @top_ndx += @game.n
    i = 0
    while i < @game.n
      @backup[@top_ndx + i] = @evaluator.piece_balance_per_column[i]
      i += 1
    @top_ndx += @game.n
    @backup[@top_ndx++] = @game.zobrist_a
    @backup[@top_ndx++] = @game.zobrist_b
    @backup[@top_ndx++] = @game.zobrist_c
    @backup[@top_ndx++] = @game.current_player
    @backup[@top_ndx++] = @evaluator.manhattan_balance
    i = 0
    while i < @game.nn
      @backup[@top_ndx + i] = @game.table[i]
      i += 1
    @top_ndx += @game.nn
    null

  restore_last_mark: () ->
    @game.history.pop()
    @top_ndx -= @game.nn
    i = 0
    while i < @game.nn
      @game.table[i] = @backup[@top_ndx + i]
      i += 1
    @evaluator.manhattan_balance = @backup[--@top_ndx]
    @game.current_player = @backup[--@top_ndx]
    @game.zobrist_c = @backup[--@top_ndx]
    @game.zobrist_b = @backup[--@top_ndx]
    @game.zobrist_a = @backup[--@top_ndx]
    i = 0
    @top_ndx -= @game.n
    while i < @game.n
      @evaluator.piece_balance_per_column[i] = @backup[@top_ndx + i]
      i += 1
    i = 0
    @top_ndx -= @game.n
    while i < @game.n
      @evaluator.piece_balance_per_row[i] = @backup[@top_ndx + i]
      i += 1
    @evaluator.game_over = false
    null
