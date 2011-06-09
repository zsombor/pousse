{square_sides} = require 'square'

module.exports = class MoveList
  constructor: (@game) ->
    @list = []
    odd = @game.n % 2 == 1
    half = Math.floor(@game.n / 2)
    insert_move_from_ndx =  (ndx) =>
      @list.push({ndx: ndx, side: square_sides.top},
                 {ndx: ndx, side: square_sides.left},
                 {ndx: ndx, side: square_sides.bottom},
                 {ndx: ndx, side: square_sides.right})
    if odd
      insert_move_from_ndx half
    i = half - 1
    while i >= 0
      insert_move_from_ndx(i)
      insert_move_from_ndx(@game.n - i - 1)
      i -= 1
    return true

  moves: (tt_hint) ->
    m = []
    if tt_hint? and tt_hint.best_move?
      m.push(tt_hint.best_move)
    m.concat(@list)

  print_list: () ->
    str = []
    ("#{move.ndx}##{move.side}" for move in @list).join(', ')
