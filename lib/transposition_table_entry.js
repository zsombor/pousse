(function() {
  var TranspositionTableEntry, max_value, positional_value;
  positional_value = require('square').positional_value;
  max_value = require('square').max_value;
  module.exports = TranspositionTableEntry = (function() {
    function TranspositionTableEntry(player, depth, position_value, position_value_type, best_move, zobrist, search_id) {
      this.player = player;
      this.depth = depth;
      this.position_value = position_value;
      this.position_value_type = position_value_type;
      this.best_move = best_move;
      this.zobrist = zobrist;
      this.search_id = search_id;
      return;
    }
    TranspositionTableEntry.prototype.upper_bound = function() {
      if (this.position_value_type === positional_value.exact || this.position_value_type === positional_value.upper_bound) {
        return this.position_value;
      }
      return max_value;
    };
    TranspositionTableEntry.prototype.lower_bound = function() {
      if (this.position_value_type === positional_value.exact || this.position_value_type === positional_value.lower_bound) {
        return this.position_value;
      }
      return -max_value;
    };
    return TranspositionTableEntry;
  })();
}).call(this);
