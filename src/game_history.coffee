{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'


module.exports = class GameHistory
  constructor: (@game) ->
    @visited = {}
    @loop_encountered = false

  push_current_board: () ->
    @loop_encountered = @visited[@game.zobrist_a] == @game.zobrist_b
    @visited[@game.zobrist_a] =  @game.zobrist_b

  pop: () ->
    @loop_encountered = false
    @visited[@game.zobrist_a] = null