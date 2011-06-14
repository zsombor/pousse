TranspositionTable = require 'transposition_table'
Evaluator = require 'evaluator'
Undo = require 'undo'
MoveList = require 'move_list'
GameHistory = require 'game_history'
MoveParser = require 'move_parser'
{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'
{positional_value} = require 'square'
Readline = require 'readline'



module.exports = class Game
  constructor: (@n) ->
    @nn = n * n
    @maximum_search_depth = 12
    @current_player = square.black
    @table = new Array(@nn)
    i = 0
    while i < @nn
      @table[i] = square.empty
      i += 1
    @zobrist_a = 0
    @zobrist_b = 0
    @history = new GameHistory(this)
    @moves = new MoveList(this)
    @evaluator = new Evaluator(this)
    @undo = new Undo(@evaluator, this)
    @transposition_table = new TranspositionTable(this, 4)
    @best_move = null

  alpha_beta: (alpha, beta, depth) ->
    @nr_processed_nodes += 1
    if @evaluator.is_game_over() or depth == 0
      value = @evaluator.evaluate()
      return value
    from_transposition_table = @transposition_table.retrieve()
    if from_transposition_table isnt null and from_transposition_table.depth == depth
      if from_transposition_table.lower_bound() >= beta
        @transposition_table_hits += 1
        return from_transposition_table.lower_bound()
      if from_transposition_table.upper_bound() <= alpha
        @transposition_table_hits += 1
        return from_transposition_table.upper_bound()
    a = alpha
    b = beta
    value = -max_value * @current_player
    best_move = null
    for move in @moves.moves(from_transposition_table)
      best_move ?= move
      @undo.mark()
      max_player = @current_player > 0
      this.move(move.side, move.ndx)
      if max_player
        tmp = this.alpha_beta(a, beta, depth - 1)
        @undo.restore_last_mark()
        if tmp > value
          value = tmp
          best_move = move
        a = value if a < value
        break if value >= beta
      else
        tmp = this.alpha_beta(alpha, b, depth - 1)
        @undo.restore_last_mark()
        if tmp < value
          value = tmp
          best_move = move
        b = value if b > value
        break if value <= alpha
    this.store_best_move value, beta, depth, best_move
    return value

  store_best_move: (value, beta, depth, best_move) ->
    value_type = if value >= beta
                   positional_value.lower_bound
                 else
                   positional_value.upper_bound
    @transposition_table.store(depth: depth, position_value: value, position_value_type: value_type, best_move: best_move)
    if depth == @current_iteration_depth
      #console.log "'#{best_move.side} #{best_move.ndx}' seems most promissing at depth #{depth} after processed #{@nr_processed_nodes} nodes with #{@transposition_table_hits} tt hits"
      @current_iteration_best_move = best_move
    null

  iterative_deepening: (final_depth) ->
    @transposition_table.bump_search_id()
    @current_iteration_depth = 0
    while @current_iteration_depth < final_depth
      @nr_processed_nodes = 0
      @transposition_table_hits = 0
      value = this.alpha_beta(-max_value, max_value, @current_iteration_depth)
      #console.log "game value is #{value}"
      break if Math.abs(value)is max_value
      @current_iteration_depth += 1
    @current_iteration_best_move

  readline: () ->
    if !@ri?
      @ri = Readline.createInterface(process.stdin, process.stdout)
      handle_close = () ->
        console.log('goodbye!')
        process.exit(0)
      @ri.on('close', handle_close)
    return @ri

  play: () ->
    console.log this.print_board()
    handle_input = (chunk) =>
      @parser = new MoveParser(@n)
      move = @parser.string_to_move(chunk)
      if move
        this.move(move.side, move.ndx)
        console.log this.print_board()
        console.log "\n"
        this.handle_game_over()
        console.log "Thinking ..."
        this.iterative_deepening(9)
        this.move(@current_iteration_best_move.side, @current_iteration_best_move.ndx)
        console.log this.print_board()
        console.log "\n"
        this.handle_game_over()
      else
        if chunk.match(/help|\?/)
          console.log "Moves have a `direction ndx` format, where `direction` must be top/bottom/right/left and ndx is between 0 and #{@n-1}. You will loose if your move leads to a board configuration that was already encountered. There are no cycles or draws."
        else
          if chunk.match(/quit|exit/)
            process.exit(0)
          else
            console.log "I'm baffled."
      this.readline().prompt()
    prompt = 'your move > '
    this.readline().setPrompt(prompt, prompt.length)
    this.readline().on('line', handle_input)
    this.readline().prompt()

  handle_game_over: () ->
    @evaluator.evaluate()
    if @evaluator.is_game_over()
      if @history.loop_encountered
        console.log "loop encountered"
      console.log "Game over!"
      console.log "#{if @evaluator.winning_player is square.black then 'X' else 'O' } won"
      process.exit(0)

  change_square: (pos, to) ->
    @transposition_table.update_zobrist_stamp_for_square_change(pos, to)
    @evaluator.insert_piece_at_pos(pos, to, @table[pos])
    @table[pos] = to

  move: (side, ndx) ->
    carry = @current_player
    switch side
      when square_sides.bottom
        i = (@n - 1) * @n + ndx
        last = ndx
        while i >= last
          next_carry = @table[i]
          this.change_square i, carry
          carry = next_carry
          break if carry == square.empty
          i -= @n
      when square_sides.top
        i = ndx
        last = (@n - 1) * @n + ndx
        while i <= last
          next_carry = @table[i]
          this.change_square i, carry
          carry = next_carry
          break if carry == square.empty
          i += @n
      when square_sides.left
        i = @n * ndx
        last = @n - 1 + @n * ndx
        while i <= last
          next_carry = @table[i]
          this.change_square i, carry
          carry = next_carry
          break if carry == square.empty
          i += 1
      when square_sides.right
        i = @n - 1 + @n * ndx
        last = @n * ndx
        while i >= last
          next_carry = @table[i]
          this.change_square i, carry
          carry = next_carry
          break if carry == square.empty
          i -= 1
    @current_player = -@current_player
    @transposition_table.update_zobrist_stamp_for_current_player_change()
    @history.push_current_board()

  log_alpha_beta: (alpha, beta, depth) ->
    console.log "alpha_beta(#{alpha}, #{beta}, #{depth})"
    console.log this.print_board()
    console.log "current_player=#{@current_player}"

  print_board: () ->
    decorate_square = (s) ->
      switch s
        when square.black
          'X'
        when square.empty
          '.'
        else
          'O'
    str = []
    i = 0
    while i < @nn
      str.push (decorate_square(s) for s in @table[i..i+@n-1]).join('')
      i += @n
    str.join("\n")

# game=new Game()
# game.move(square_sides.right, 2)
# game.move(square_sides.right, 2)
# game.log_board()
