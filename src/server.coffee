Game = require 'game'
MoveParser = require 'move_parser'
{square} = require 'square'
{square_sides} = require 'square'
{max_value} = require 'square'
util = require 'util'
http = require 'http'

module.exports = class Server
  constructor: (@n, @games_in_a_tournament = 1000) ->
    @i_am = square.white
    @game = new Game(@n)
    @won_as_black = 0
    @won_as_white = 0
    @lost_as_black = 0
    @lost_as_white = 0
    @parser = new MoveParser(@n)

  new_game: () ->
    @i_am = -@i_am
    @game = new Game(@n)
    move = null
    if @i_am is @game.current_player
      move = {side: 'top', ndx: Math.floor(Math.random() * @n)}
      console.log "making the first move: #{@parser.move_to_string(move)}"
      @game.move(move.side, move.ndx)
      console.log @game.print_board()
      console.log "\n"
    move

  play_game: () ->
    callback = (req, res) =>
      this.handle_opposing_move(req, res)
    @server = http.createServer(callback).listen(9090, '127.0.0.1')

  handle_opposing_move: (request, response) ->
    response.setHeader('Content-Type', 'text/plain')
    str = []
    request.addListener 'data', (chunk) =>
      str.push(chunk)
    request.addListener 'end', () =>
      move = @parser.string_to_move(str.join())
      if !move
        if str.join().match(/Game Over./)
          this.on_game_over(response)
        else
          console.log "got an illegal move '#{str.join()}'"
          response.end()
          process.exit(0)
      if move
        console.log "got move: #{str.join()}"
        @game.move(move.side, move.ndx)
        console.log @game.print_board()
        console.log "\n"
        if this.is_game_over()
          return this.on_game_over(response)
        console.log "Thinking ..."
        @game.iterative_deepening(7)
        str = @parser.move_to_string(@game.current_iteration_best_move)
        console.log "selected move '#{str}'"
        @game.move(@game.current_iteration_best_move.side, @game.current_iteration_best_move.ndx)
        console.log @game.print_board()
        console.log "\n"
        response.write(str)
        if this.is_game_over()
          return this.on_game_over(response)
      response.end()

  is_game_over: () ->
    @game.evaluator.evaluate()
    return  @game.evaluator.is_game_over()

  on_game_over: (response) ->
    # console.log @game.evaluator.print_balances()
    # console.log "loop encounterd: #{@game.history.loop_encountered}"
    if @game.evaluator.winning_player is @i_am
      console.log "I've won :-)"
      if @i_am is square.black
        @won_as_black += 1
      else
        @won_as_white += 1
    else
      console.log "I've lost :-("
      @lost += 1
      if @i_am is square.black
        @lost_as_black += 1
      else
        @lost_as_white += 1
    if @won_as_black + @lost_as_black + @won_as_white + @lost_as_white == @games_in_a_tournament
      response.write "Tournament over"
      response.end()
      console.log "Tournament over"
      this.log_tournament_results()
      process.exit()
    else
      console.log "So far"
      this.log_tournament_results()
      console.log "Starting a new game"
      move = this.new_game()
      if move
        response.write "new game, I've moved: #{@parser.move_to_string(move)}"
      else
        response.write "new game, your turn"
      response.end()

  log_tournament_results: () ->
     console.log " * as black I've won #{@won_as_black} times and lost #{@lost_as_black} times!"
     console.log " * tas white I've won #{@won_as_white} times and lost #{@lost_as_white} times!"


