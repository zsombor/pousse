(function() {
  var GameHistory, max_value, square, square_sides;
  square = require('square').square;
  square_sides = require('square').square_sides;
  max_value = require('square').max_value;
  module.exports = GameHistory = (function() {
    function GameHistory(game) {
      this.game = game;
      this.visited = {};
      this.loop_encountered = false;
    }
    GameHistory.prototype.push_current_board = function() {
      var key;
      key = [this.game.zobrist_b, this.game.zobrist_a].join('_');
      this.loop_encountered = this.visited[key] === true;
      return this.visited[key] = true;
    };
    GameHistory.prototype.pop = function() {
      var key;
      key = [this.game.zobrist_b, this.game.zobrist_a].join('_');
      if (!this.loop_encountered) {
        delete this.visited[key];
      }
      return this.loop_encountered = false;
    };
    return GameHistory;
  })();
}).call(this);
