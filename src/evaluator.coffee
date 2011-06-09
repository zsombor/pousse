{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'


module.exports = class Evaluator
  constructor: (@game) ->
    @piece_balance_per_column = new Array(@game.n)
    @piece_balance_per_row = new Array(@game.n)
    @balance2value = new Array(@game.n)
    @two_on_power_of_n_plus_two = Math.pow(2, @game.n + 2)
    i = 0
    while i < @game.n
     @piece_balance_per_row[i] = 0
     @piece_balance_per_column[i] = 0
     i += 1
    i = 0
    while i <= @game.n
     @balance2value[i] = Math.pow(2, i) - 1
     i += 1

  insert_piece_at_pos: (pos, new_piece, prev_piece) ->
    column = pos % @game.n
    row = (pos - column)/ @game.n
    change = new_piece - prev_piece
    @piece_balance_per_row[row] += change
    @piece_balance_per_column[column] += change

  is_game_over: () ->
    return @game_over if @game_over
    @game_over = false
    if @game.history.loop_encountered
      @winning_player = @game.current_player
      return (@game_over = true)
    i = 0
    black_lines = 0
    white_lines = 0
    while i < @game.n
      if @piece_balance_per_row[i] is @game.n or @piece_balance_per_column[i] is @game.n
        black_lines += 1
      if @piece_balance_per_row[i] is -@game.n or @piece_balance_per_column[i] is -@game.n
        white_lines += 1
      i += 1
    if black_lines != white_lines
      @winning_player = (if black_lines > white_lines then square.black else square.white)
      return @game_over = true
    @winning_player = square.empty
    false

  evaluate: () ->
    if this.is_game_over()
      return @winning_player * max_value
    sum = 0
    for balance in @piece_balance_per_row
      sum += @balance2value[Math.abs(balance)] * (if balance >= 0 then 1 else -1)
    for balance in @piece_balance_per_column
      sum += @balance2value[Math.abs(balance)] * (if balance >= 0 then 1 else -1)
    (max_value * sum) / @two_on_power_of_n_plus_two

  print_balances: () ->
    ['col: ', @piece_balance_per_column.join(','), ' ',
     'row: ', @piece_balance_per_row.join(',')].join('')
