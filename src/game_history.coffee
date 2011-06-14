{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'


module.exports = class GameHistory
  constructor: (@game) ->
    @visited = {}
    @loop_encountered = false

  push_current_board: () ->
    key = [ @game.zobrist_a, @game.zobrist_b, @game.zobrist_c].join('_')
    @loop_encountered = (@visited[key] is true)
    @visited[key] =  true

  pop: () ->
    key = [ @game.zobrist_a, @game.zobrist_b, @game.zobrist_c].join('_')
    delete @visited[key] if !@loop_encountered
    @loop_encountered = false