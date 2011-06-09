(function() {
  var Undo;
  module.exports = Undo = (function() {
    function Undo(evaluator, game) {
      this.evaluator = evaluator;
      this.game = game;
      this.backup = new Array((this.game.n * 2 + 2 + 1 + this.game.nn) * this.game.maximum_search_depth);
      this.top_ndx = 0;
    }
    Undo.prototype.mark = function() {
      var i;
      i = 0;
      while (i < this.game.n) {
        this.backup[this.top_ndx + i] = this.evaluator.piece_balance_per_row[i];
        i += 1;
      }
      this.top_ndx += this.game.n;
      i = 0;
      while (i < this.game.n) {
        this.backup[this.top_ndx + i] = this.evaluator.piece_balance_per_column[i];
        i += 1;
      }
      this.top_ndx += this.game.n;
      this.backup[this.top_ndx] = this.game.zobrist_a;
      this.backup[this.top_ndx + 1] = this.game.zobrist_b;
      this.backup[this.top_ndx + 2] = this.game.current_player;
      this.top_ndx += 3;
      i = 0;
      while (i < this.game.nn) {
        this.backup[this.top_ndx + i] = this.game.table[i];
        i += 1;
      }
      this.top_ndx += this.game.nn;
      return null;
    };
    Undo.prototype.restore_last_mark = function() {
      var i;
      this.game.history.pop();
      this.top_ndx -= this.game.nn;
      i = 0;
      while (i < this.game.nn) {
        this.game.table[i] = this.backup[this.top_ndx + i];
        i += 1;
      }
      this.top_ndx -= 3;
      this.game.zobrist_a = this.backup[this.top_ndx];
      this.game.zobrist_b = this.backup[this.top_ndx + 1];
      this.game.current_player = this.backup[this.top_ndx + 2];
      i = 0;
      this.top_ndx -= this.game.n;
      while (i < this.game.n) {
        this.evaluator.piece_balance_per_column[i] = this.backup[this.top_ndx + i];
        i += 1;
      }
      i = 0;
      this.top_ndx -= this.game.n;
      while (i < this.game.n) {
        this.evaluator.piece_balance_per_row[i] = this.backup[this.top_ndx + i];
        i += 1;
      }
      this.evaluator.game_over = false;
      return null;
    };
    return Undo;
  })();
}).call(this);
