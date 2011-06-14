(function() {
  var Evaluator, max_value, square, square_sides;
  square = require('square').square;
  square_sides = require('square').square_sides;
  max_value = require('square').max_value;
  module.exports = Evaluator = (function() {
    function Evaluator(game) {
      var column, i, row;
      this.game = game;
      this.piece_balance_per_column = new Array(this.game.n);
      this.piece_balance_per_row = new Array(this.game.n);
      this.manhattan_balance = 0;
      this.balance2value = new Array(this.game.n);
      this.manhattan_distances = new Array(this.game.nn);
      this.two_on_power_of_n_plus_two = Math.pow(2, this.game.n + 3);
      i = 0;
      while (i < this.game.n) {
        this.piece_balance_per_row[i] = 0;
        this.piece_balance_per_column[i] = 0;
        i += 1;
      }
      i = 0;
      while (i <= this.game.n) {
        this.balance2value[i] = Math.pow(2, i) - 1;
        i += 1;
      }
      i = 0;
      while (i < this.game.nn) {
        column = i % this.game.n;
        row = (i - column) / this.game.n;
        this.manhattan_distances[i] = (row < this.game.n - row - 1 ? row : this.game.n - row - 1);
        this.manhattan_distances[i] += (column < this.game.n - column - 1 ? column : this.game.n - column - 1);
        i += 1;
      }
    }
    Evaluator.prototype.insert_piece_at_pos = function(pos, new_piece, prev_piece) {
      var change, column, manhattan_distance_from_center, row;
      column = pos % this.game.n;
      row = (pos - column) / this.game.n;
      change = new_piece - prev_piece;
      manhattan_distance_from_center = this.manhattan_balance += this.manhattan_distances[pos] * change;
      this.piece_balance_per_row[row] += change;
      return this.piece_balance_per_column[column] += change;
    };
    Evaluator.prototype.is_game_over = function() {
      var black_lines, i, white_lines;
      if (this.game_over) {
        return this.game_over;
      }
      this.game_over = false;
      if (this.game.history.loop_encountered) {
        this.winning_player = this.game.current_player;
        return this.game_over = true;
      }
      i = 0;
      black_lines = 0;
      white_lines = 0;
      while (i < this.game.n) {
        if (this.piece_balance_per_row[i] === this.game.n || this.piece_balance_per_column[i] === this.game.n) {
          black_lines += 1;
        }
        if (this.piece_balance_per_row[i] === -this.game.n || this.piece_balance_per_column[i] === -this.game.n) {
          white_lines += 1;
        }
        i += 1;
      }
      if (black_lines !== white_lines) {
        this.winning_player = (black_lines > white_lines ? square.black : square.white);
        return this.game_over = true;
      }
      this.winning_player = square.empty;
      return false;
    };
    Evaluator.prototype.evaluate = function() {
      var balance, sum, _i, _j, _len, _len2, _ref, _ref2;
      if (this.is_game_over()) {
        return this.winning_player * max_value;
      }
      sum = 0;
      sum += this.manhattan_balance;
      _ref = this.piece_balance_per_row;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        balance = _ref[_i];
        sum += this.balance2value[Math.abs(balance)] * (balance >= 0 ? 1 : -1);
      }
      _ref2 = this.piece_balance_per_column;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        balance = _ref2[_j];
        sum += this.balance2value[Math.abs(balance)] * (balance >= 0 ? 1 : -1);
      }
      return (max_value * sum) / this.two_on_power_of_n_plus_two;
    };
    Evaluator.prototype.print_balances = function() {
      return ['col: ', this.piece_balance_per_column.join(','), ' ', 'row: ', this.piece_balance_per_row.join(',')].join('');
    };
    return Evaluator;
  })();
}).call(this);
