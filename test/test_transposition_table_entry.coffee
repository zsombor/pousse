TranspositionTableEntry = require 'transposition_table_entry'
{square} = require 'square'
{square_sides} = require 'square'
{positional_value} = require 'square'
{max_value} = require 'square'
{testCase} = require 'nodeunit'

module.exports = testCase
  setUp: (done) ->
    @record = new TranspositionTableEntry(square.black, 13, 777, positional_value.exact, 13, 1234567, 98765)
    done()

  zobrist: (test) ->
    test.equal 1234567, @record.zobrist_b
    test.equal 98765, @record.zobrist_c
    test.done()

  lower_bound_when_exact_value_is_stored: (test) ->
    test.equal positional_value.exact, @record.position_value_type
    test.equal 777, @record.position_value
    test.equal 777, @record.lower_bound()
    test.done()

  lower_bound_when_lower_bound_is_stored: (test) ->
    @record.position_value_type = positional_value.lower_bound
    test.equal 777, @record.position_value
    test.equal 777, @record.lower_bound()
    test.done()

  lower_bound_when_upper_bound_is_stored: (test) ->
    @record.position_value_type = positional_value.upper_bound
    test.equal 777, @record.position_value
    test.equal -max_value, @record.lower_bound()
    test.done()

  upper_bound_when_exact_value_is_stored: (test) ->
    test.equal positional_value.exact, @record.position_value_type
    test.equal 777, @record.position_value
    test.equal 777, @record.upper_bound()
    test.done()

  upper_bound_when_upper_bound_is_stored: (test) ->
    @record.position_value_type = positional_value.upper_bound
    test.equal 777, @record.position_value
    test.equal 777, @record.upper_bound()
    test.done()

  upper_bound_when_lower_bound_is_stored: (test) ->
    @record.position_value_type = positional_value.lower_bound
    test.equal 777, @record.position_value
    test.equal max_value, @record.upper_bound()
    test.done()


