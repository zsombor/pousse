(function() {
  var TranspositionTable, TranspositionTableEntry, square;
  TranspositionTableEntry = require('transposition_table_entry');
  square = require('square').square;
  module.exports = TranspositionTable = (function() {
    function TranspositionTable(game, log_size) {
      var i, max_positive_integer;
      this.game = game;
      this.log_size = log_size != null ? log_size : 15;
      this.size = Math.pow(2, this.log_size);
      this.table = new Array(this.size);
      this.current_search_id = 0;
      i = 0;
      while (i < this.size) {
        this.table[i] = new TranspositionTableEntry(square.empty, 0, 0, 0, 0, 0, 0);
        i += 1;
      }
      this.xor_table_a = new Array(this.game.nn * 3 + 3);
      this.xor_table_b = new Array(this.game.nn * 3 + 3);
      i = 0;
      max_positive_integer = 256 * 256 * 256 * 64;
      while (i < this.game.nn * 3 + 3) {
        this.xor_table_a[i] = Math.floor(Math.random() * max_positive_integer);
        this.xor_table_b[i] = Math.floor(Math.random() * max_positive_integer);
        i += 1;
      }
      this.reset_zobrist_stamp_for_game();
    }
    TranspositionTable.prototype.bump_search_id = function() {
      return this.current_search_id += 1;
    };
    TranspositionTable.prototype.hash = function() {
      return this.game.zobrist_a >> (32 - this.log_size);
    };
    TranspositionTable.prototype.retrieve = function() {
      var ndx;
      ndx = this.hash();
      if (this.game.table[ndx].zobrist !== this.table[ndx].zobrist_b || this.game.current_player !== this.table[ndx].player) {
        return null;
      } else {
        return this.table[ndx];
      }
    };
    TranspositionTable.prototype.store = function(values) {
      var ndx;
      ndx = this.hash();
      if (values.depth >= this.table[ndx].depth || this.table[ndx].search_id !== this.current_search_id) {
        this.table[ndx].zobrist = this.game.zobrist_b;
        this.table[ndx].player = this.game.current_player;
        this.table[ndx].depth = values.depth;
        this.table[ndx].position_value = values.position_value;
        this.table[ndx].position_value_type = values.position_value_type;
        return this.table[ndx].best_move = values.best_move;
      }
    };
    TranspositionTable.prototype.update_zobrist_stamp_for_square_change = function(pos, changed_to) {
      this.game.zobrist_a ^= this.xor_table_a[pos + (this.game.table[pos] + 1)] ^ this.xor_table_a[pos + (changed_to + 1)];
      return this.game.zobrist_b ^= this.xor_table_b[pos + (this.game.table[pos] + 1)] ^ this.xor_table_b[pos + (changed_to + 1)];
    };
    TranspositionTable.prototype.update_zobrist_stamp_for_current_player_change = function() {};
    TranspositionTable.prototype.reset_zobrist_stamp_for_game = function() {
      var i, _results;
      this.game.zobrist_a = 0;
      this.game.zobrist_b = 0;
      i = 0;
      _results = [];
      while (i < this.game.nn) {
        this.game.zobrist_a ^= this.xor_table_a[i + (this.game.table[i] + 1)];
        this.game.zobrist_b ^= this.xor_table_b[i + (this.game.table[i] + 1)];
        _results.push(i += 1);
      }
      return _results;
    };
    return TranspositionTable;
  })();
}).call(this);
