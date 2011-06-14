{square} = require 'square'
{square_sides} = require 'square'

module.exports = class MoveParser
  constructor: (@n) ->
    #

  move_to_string: (move) ->
    a = []
    switch move.side
      when square_sides.top
        a.push 'top'
      when square_sides.left
        a.push 'left'
      when square_sides.right
        a.push 'right'
      when square_sides.bottom
        a.push 'bottom'
    a.push(move.ndx)
    return a.join(' ')

  string_to_move: (string) ->
    match = string.match(/\s*(left|right|top|bottom)\s*(\d+)/)
    if match
      ndx = parseInt(match[2])
      side = switch match[1]
               when 'top'
                 square_sides.top
               when 'left'
                 square_sides.left
               when 'bottom'
                 square_sides.bottom
               when 'right'
                 square_sides.right
      if ndx >= 0 and ndx < @n
        return {side: side, ndx: ndx}
      else
        console.log "'#{string}' is not on the board."
    null