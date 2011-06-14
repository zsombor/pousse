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
        this.table[i] = new TranspositionTableEntry(square.empty, 0, 0, 0, 0, 0, 0, 0);
        i += 1;
      }
      this.xor_table_a = new Array(this.game.nn * 3);
      this.xor_table_b = new Array(this.game.nn * 3);
      this.xor_table_c = new Array(this.game.nn * 3);
      i = 0;
      max_positive_integer = 256 * 256 * 256 * 64;
      while (i < this.game.nn * 3) {
        this.xor_table_a[i] = Math.floor(Math.random() * max_positive_integer);
        this.xor_table_b[i] = Math.floor(Math.random() * max_positive_integer);
        this.xor_table_c[i] = Math.floor(Math.random() * max_positive_integer);
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
      var hit, ndx;
      ndx = this.hash();
      hit = this.table[ndx];
      if (this.game.zobrist_b !== hit.zobrist_b || this.game.zobrist_c !== hit.zobrist_c || this.game.current_player !== hit.player) {
        return null;
      } else {
        return hit;
      }
    };
    TranspositionTable.prototype.store = function(values) {
      var ndx;
      ndx = this.hash();
      if (values.depth >= this.table[ndx].depth || this.table[ndx].search_id !== this.current_search_id) {
        this.table[ndx].zobrist_b = this.game.zobrist_b;
        this.table[ndx].zobrist_c = this.game.zobrist_c;
        this.table[ndx].player = this.game.current_player;
        this.table[ndx].depth = values.depth;
        this.table[ndx].position_value = values.position_value;
        this.table[ndx].position_value_type = values.position_value_type;
        return this.table[ndx].best_move = values.best_move;
      }
    };
    TranspositionTable.prototype.update_zobrist_stamp_for_square_change = function(pos, changed_to) {
      var from, to;
      from = pos + (this.game.table[pos] + 1);
      to = pos + (changed_to + 1);
      this.game.zobrist_a ^= this.xor_table_a[from] ^ this.xor_table_a[to];
      this.game.zobrist_b ^= this.xor_table_b[from] ^ this.xor_table_b[to];
      this.game.zobrist_c ^= this.xor_table_c[from] ^ this.xor_table_c[to];
      return true;
    };
    TranspositionTable.prototype.reset_zobrist_stamp_for_game = function() {
      var i, ndx, _results;
      this.game.zobrist_a = 0;
      this.game.zobrist_b = 0;
      this.game.zobrist_c = 0;
      i = 0;
      _results = [];
      while (i < this.game.nn) {
        ndx = i + (this.game.table[i] + 1);
        this.game.zobrist_a ^= this.xor_table_a[ndx];
        this.game.zobrist_b ^= this.xor_table_b[ndx];
        this.game.zobrist_c ^= this.xor_table_c[ndx];
        _results.push(i += 1);
      }
      return _results;
    };
    return TranspositionTable;
  })();
}).call(this);
