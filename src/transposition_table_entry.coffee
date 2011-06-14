{positional_value} = require 'square'
{max_value} = require 'square'

module.exports = class TranspositionTableEntry
  constructor: (@player, @depth, @position_value, @position_value_type, @best_move, @zobrist_b, @zobrist_c, @search_id) ->
    return

  upper_bound: () ->
    if @position_value_type == positional_value.exact or @position_value_type == positional_value.upper_bound
      return @position_value
    return max_value

  lower_bound: () ->
    if @position_value_type == positional_value.exact or @position_value_type == positional_value.lower_bound
      return @position_value
    return -max_value