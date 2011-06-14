(function() {
  var Evaluator, Game, GameHistory, MoveList, MoveParser, Readline, TranspositionTable, Undo, max_value, positional_value, square, square_sides;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  TranspositionTable = require('transposition_table');
  Evaluator = require('evaluator');
  Undo = require('undo');
  MoveList = require('move_list');
  GameHistory = require('game_history');
  MoveParser = require('move_parser');
  square = require('square').square;
  square_sides = require('square').square_sides;
  max_value = require('square').max_value;
  positional_value = require('square').positional_value;
  Readline = require('readline');
  module.exports = Game = (function() {
    function Game(n) {
      var i;
      this.n = n;
      this.nn = n * n;
      this.maximum_search_depth = 12;
      this.current_player = square.black;
      this.table = new Array(this.nn);
      i = 0;
      while (i < this.nn) {
        this.table[i] = square.empty;
        i += 1;
      }
      this.zobrist_a = 0;
      this.zobrist_b = 0;
      this.history = new GameHistory(this);
      this.moves = new MoveList(this);
      this.evaluator = new Evaluator(this);
      this.undo = new Undo(this.evaluator, this);
      this.transposition_table = new TranspositionTable(this, 4);
      this.best_move = null;
    }
    Game.prototype.alpha_beta = function(alpha, beta, depth) {
      var a, b, best_move, from_transposition_table, max_player, move, tmp, value, _i, _len, _ref;
      this.nr_processed_nodes += 1;
      if (this.evaluator.is_game_over() || depth === 0) {
        value = this.evaluator.evaluate();
        return value;
      }
      from_transposition_table = this.transposition_table.retrieve();
      if (from_transposition_table !== null && from_transposition_table.depth === depth) {
        if (from_transposition_table.lower_bound() >= beta) {
          this.transposition_table_hits += 1;
          return from_transposition_table.lower_bound();
        }
        if (from_transposition_table.upper_bound() <= alpha) {
          this.transposition_table_hits += 1;
          return from_transposition_table.upper_bound();
        }
      }
      a = alpha;
      b = beta;
      value = -max_value * this.current_player;
      best_move = null;
      _ref = this.moves.moves(from_transposition_table);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        move = _ref[_i];
                if (best_move != null) {
          best_move;
        } else {
          best_move = move;
        };
        this.undo.mark();
        max_player = this.current_player > 0;
        this.move(move.side, move.ndx);
        if (max_player) {
          tmp = this.alpha_beta(a, beta, depth - 1);
          this.undo.restore_last_mark();
          if (tmp > value) {
            value = tmp;
            best_move = move;
          }
          if (a < value) {
            a = value;
          }
          if (value >= beta) {
            break;
          }
        } else {
          tmp = this.alpha_beta(alpha, b, depth - 1);
          this.undo.restore_last_mark();
          if (tmp < value) {
            value = tmp;
            best_move = move;
          }
          if (b > value) {
            b = value;
          }
          if (value <= alpha) {
            break;
          }
        }
      }
      this.store_best_move(value, beta, depth, best_move);
      return value;
    };
    Game.prototype.store_best_move = function(value, beta, depth, best_move) {
      var value_type;
      value_type = value >= beta ? positional_value.lower_bound : positional_value.upper_bound;
      this.transposition_table.store({
        depth: depth,
        position_value: value,
        position_value_type: value_type,
        best_move: best_move
      });
      if (depth === this.current_iteration_depth) {
        this.current_iteration_best_move = best_move;
      }
      return null;
    };
    Game.prototype.iterative_deepening = function(final_depth) {
      var value;
      this.transposition_table.bump_search_id();
      this.current_iteration_depth = 0;
      while (this.current_iteration_depth < final_depth) {
        this.nr_processed_nodes = 0;
        this.transposition_table_hits = 0;
        value = this.alpha_beta(-max_value, max_value, this.current_iteration_depth);
        if (Math.abs(value) === max_value) {
          break;
        }
        this.current_iteration_depth += 1;
      }
      return this.current_iteration_best_move;
    };
    Game.prototype.readline = function() {
      var handle_close;
      if (!(this.ri != null)) {
        this.ri = Readline.createInterface(process.stdin, process.stdout);
        handle_close = function() {
          console.log('goodbye!');
          return process.exit(0);
        };
        this.ri.on('close', handle_close);
      }
      return this.ri;
    };
    Game.prototype.play = function() {
      var handle_input, prompt;
      console.log(this.print_board());
      handle_input = __bind(function(chunk) {
        var move;
        this.parser = new MoveParser(this.n);
        move = this.parser.string_to_move(chunk);
        if (move) {
          this.move(move.side, move.ndx);
          console.log(this.print_board());
          console.log("\n");
          this.handle_game_over();
          console.log("Thinking ...");
          this.iterative_deepening(9);
          this.move(this.current_iteration_best_move.side, this.current_iteration_best_move.ndx);
          console.log(this.print_board());
          console.log("\n");
          this.handle_game_over();
        } else {
          if (chunk.match(/help|\?/)) {
            console.log("Moves have a `direction ndx` format, where `direction` must be top/bottom/right/left and ndx is between 0 and " + (this.n - 1) + ". You will loose if your move leads to a board configuration that was already encountered. There are no cycles or draws.");
          } else {
            if (chunk.match(/quit|exit/)) {
              process.exit(0);
            } else {
              console.log("I'm baffled.");
            }
          }
        }
        return this.readline().prompt();
      }, this);
      prompt = 'your move > ';
      this.readline().setPrompt(prompt, prompt.length);
      this.readline().on('line', handle_input);
      return this.readline().prompt();
    };
    Game.prototype.handle_game_over = function() {
      this.evaluator.evaluate();
      if (this.evaluator.is_game_over()) {
        if (this.history.loop_encountered) {
          console.log("loop encountered");
        }
        console.log("Game over!");
        console.log("" + (this.evaluator.winning_player === square.black ? 'X' : 'O') + " won");
        return process.exit(0);
      }
    };
    Game.prototype.change_square = function(pos, to) {
      this.transposition_table.update_zobrist_stamp_for_square_change(pos, to);
      this.evaluator.insert_piece_at_pos(pos, to, this.table[pos]);
      return this.table[pos] = to;
    };
    Game.prototype.move = function(side, ndx) {
      var carry, i, last, next_carry;
      carry = this.current_player;
      switch (side) {
        case square_sides.bottom:
          i = (this.n - 1) * this.n + ndx;
          last = ndx;
          while (i >= last) {
            next_carry = this.table[i];
            this.change_square(i, carry);
            carry = next_carry;
            if (carry === square.empty) {
              break;
            }
            i -= this.n;
          }
          break;
        case square_sides.top:
          i = ndx;
          last = (this.n - 1) * this.n + ndx;
          while (i <= last) {
            next_carry = this.table[i];
            this.change_square(i, carry);
            carry = next_carry;
            if (carry === square.empty) {
              break;
            }
            i += this.n;
          }
          break;
        case square_sides.left:
          i = this.n * ndx;
          last = this.n - 1 + this.n * ndx;
          while (i <= last) {
            next_carry = this.table[i];
            this.change_square(i, carry);
            carry = next_carry;
            if (carry === square.empty) {
              break;
            }
            i += 1;
          }
          break;
        case square_sides.right:
          i = this.n - 1 + this.n * ndx;
          last = this.n * ndx;
          while (i >= last) {
            next_carry = this.table[i];
            this.change_square(i, carry);
            carry = next_carry;
            if (carry === square.empty) {
              break;
            }
            i -= 1;
          }
      }
      this.current_player = -this.current_player;
      this.transposition_table.update_zobrist_stamp_for_current_player_change();
      return this.history.push_current_board();
    };
    Game.prototype.log_alpha_beta = function(alpha, beta, depth) {
      console.log("alpha_beta(" + alpha + ", " + beta + ", " + depth + ")");
      console.log(this.print_board());
      return console.log("current_player=" + this.current_player);
    };
    Game.prototype.print_board = function() {
      var decorate_square, i, s, str;
      decorate_square = function(s) {
        switch (s) {
          case square.black:
            return 'X';
          case square.empty:
            return '.';
          default:
            return 'O';
        }
      };
      str = [];
      i = 0;
      while (i < this.nn) {
        str.push(((function() {
          var _i, _len, _ref, _results;
          _ref = this.table.slice(i, (i + this.n - 1 + 1) || 9e9);
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            s = _ref[_i];
            _results.push(decorate_square(s));
          }
          return _results;
        }).call(this)).join(''));
        i += this.n;
      }
      return str.join("\n");
    };
    return Game;
  })();
}).call(this);
