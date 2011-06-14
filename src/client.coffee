Game = require 'game'
MoveParser = require 'move_parser'
{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'
util = require 'util'
http = require 'http'

module.exports = class Client
  constructor: (@n) ->
    @parser = new MoveParser(@n)
    @game = new Game(@n)
    @won = 0
    @lost = 0

  play_game: () ->
    console.log "Thinking ..."
    @game.iterative_deepening(7)
    my_move = @game.current_iteration_best_move
    console.log "selected move '#{@parser.move_to_string(my_move)}'"
    @game.move my_move.side, my_move.ndx
    console.log @game.print_board()
    console.log "\n"
    server_move = []
    req = http.request {host: '127.0.0.1', port: 9090, method: 'POST', path: '/'}, (res) =>
      res.on 'data', (chunk) =>
        server_move.push(chunk)
      res.on 'end', () =>
        this.handle_server_reply(server_move.join())
    req.write(@parser.move_to_string(my_move))
    req.end()
    true

  handle_server_reply: (body) ->
    if body.match(/Tournament/)
      console.log "Tournament over"
      process.exit(0)
    if body.match /^\s*(top|bottom|right|left)\s*/
      move = @parser.string_to_move(body)
      console.log "got move '#{@parser.move_to_string(move)}'"
      @game.move(move.side, move.ndx)
      console.log @game.print_board()
      console.log "\n"
      body = body.replace(@parser.move_to_string(move))
    if (this.is_game_over() and !body.match(/new game/)) or (!this.is_game_over() and body.match(/new game/))
      console.log "I'm out of sync with the server, aborting"
      process.exit(0)
    if body.match( /new game/ )
      console.log "Game over"
      @game = new Game(@n)
      if body.match(/your turn/)
        console.log "My turn"
      else
        move = @parser.string_to_move(body)
        console.log "Server starts with new move: #{@parser.move_to_string(move)}"
        @game.move(move.side, move.ndx)
        console.log @game.print_board()
        console.log "\n"
    play_game_latter = () =>
      this.play_game()
    setTimeout play_game_latter, 200
    true

  is_game_over: () ->
    @game.evaluator.evaluate()
    return  @game.evaluator.is_game_over()



