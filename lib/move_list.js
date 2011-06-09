(function() {
  var MoveList, square_sides;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  square_sides = require('square').square_sides;
  module.exports = MoveList = (function() {
    function MoveList(game) {
      var half, i, insert_move_from_ndx, odd;
      this.game = game;
      this.list = [];
      odd = this.game.n % 2 === 1;
      half = Math.floor(this.game.n / 2);
      insert_move_from_ndx = __bind(function(ndx) {
        return this.list.push({
          ndx: ndx,
          side: square_sides.top
        }, {
          ndx: ndx,
          side: square_sides.left
        }, {
          ndx: ndx,
          side: square_sides.bottom
        }, {
          ndx: ndx,
          side: square_sides.right
        });
      }, this);
      if (odd) {
        insert_move_from_ndx(half);
      }
      i = half - 1;
      while (i >= 0) {
        insert_move_from_ndx(i);
        insert_move_from_ndx(this.game.n - i - 1);
        i -= 1;
      }
      return true;
    }
    MoveList.prototype.moves = function(tt_hint) {
      var m;
      m = [];
      if ((tt_hint != null) && (tt_hint.best_move != null)) {
        m.push(tt_hint.best_move);
      }
      return m.concat(this.list);
    };
    MoveList.prototype.print_list = function() {
      var move, str;
      str = [];
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.list;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          move = _ref[_i];
          _results.push("" + move.ndx + "#" + move.side);
        }
        return _results;
      }).call(this)).join(', ');
    };
    return MoveList;
  })();
}).call(this);
