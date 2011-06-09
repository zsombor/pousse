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
      this.loop_encountered = this.visited[this.game.zobrist_a] === this.game.zobrist_b;
      return this.visited[this.game.zobrist_a] = this.game.zobrist_b;
    };
    GameHistory.prototype.pop = function() {
      this.loop_encountered = false;
      return this.visited[this.game.zobrist_a] = null;
    };
    return GameHistory;
  })();
}).call(this);
