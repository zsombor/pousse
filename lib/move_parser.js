(function() {
  var MoveParser, square, square_sides;
  square = require('square').square;
  square_sides = require('square').square_sides;
  module.exports = MoveParser = (function() {
    function MoveParser(n) {
      this.n = n;
    }
    MoveParser.prototype.move_to_string = function(move) {
      var a;
      a = [];
      switch (move.side) {
        case square_sides.top:
          a.push('top');
          break;
        case square_sides.left:
          a.push('left');
          break;
        case square_sides.right:
          a.push('right');
          break;
        case square_sides.bottom:
          a.push('bottom');
      }
      a.push(move.ndx);
      return a.join(' ');
    };
    MoveParser.prototype.string_to_move = function(string) {
      var match, ndx, side;
      match = string.match(/\s*(left|right|top|bottom)\s*(\d+)/);
      if (match) {
        ndx = parseInt(match[2]);
        side = (function() {
          switch (match[1]) {
            case 'top':
              return square_sides.top;
            case 'left':
              return square_sides.left;
            case 'bottom':
              return square_sides.bottom;
            case 'right':
              return square_sides.right;
          }
        })();
        if (ndx >= 0 && ndx < this.n) {
          return {
            side: side,
            ndx: ndx
          };
        } else {
          console.log("'" + string + "' is not on the board.");
        }
      }
      return null;
    };
    return MoveParser;
  })();
}).call(this);
