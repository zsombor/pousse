(function() {
  var Game, MoveParser, Server, http, max_value, square, square_sides, util;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Game = require('game');
  MoveParser = require('move_parser');
  square = require('square').square;
  square_sides = require('square').square_sides;
  max_value = require('square').max_value;
  util = require('util');
  http = require('http');
  module.exports = Server = (function() {
    function Server(n, games_in_a_tournament) {
      this.n = n;
      this.games_in_a_tournament = games_in_a_tournament != null ? games_in_a_tournament : 1000;
      this.i_am = square.white;
      this.game = new Game(this.n);
      this.won_as_black = 0;
      this.won_as_white = 0;
      this.lost_as_black = 0;
      this.lost_as_white = 0;
      this.parser = new MoveParser(this.n);
    }
    Server.prototype.new_game = function() {
      var move;
      this.i_am = -this.i_am;
      this.game = new Game(this.n);
      move = null;
      if (this.i_am === this.game.current_player) {
        move = {
          side: 'top',
          ndx: Math.floor(Math.random() * this.n)
        };
        console.log("making the first move: " + (this.parser.move_to_string(move)));
        this.game.move(move.side, move.ndx);
        console.log(this.game.print_board());
        console.log("\n");
      }
      return move;
    };
    Server.prototype.play_game = function() {
      var callback;
      callback = __bind(function(req, res) {
        return this.handle_opposing_move(req, res);
      }, this);
      return this.server = http.createServer(callback).listen(9090, '127.0.0.1');
    };
    Server.prototype.handle_opposing_move = function(request, response) {
      var str;
      response.setHeader('Content-Type', 'text/plain');
      str = [];
      request.addListener('data', __bind(function(chunk) {
        return str.push(chunk);
      }, this));
      return request.addListener('end', __bind(function() {
        var move;
        move = this.parser.string_to_move(str.join());
        if (!move) {
          if (str.join().match(/Game Over./)) {
            this.on_game_over(response);
          } else {
            console.log("got an illegal move '" + (str.join()) + "'");
            response.end();
            process.exit(0);
          }
        }
        if (move) {
          console.log("got move: " + (str.join()));
          this.game.move(move.side, move.ndx);
          console.log(this.game.print_board());
          console.log("\n");
          if (this.is_game_over()) {
            return this.on_game_over(response);
          }
          console.log("Thinking ...");
          this.game.iterative_deepening(7);
          str = this.parser.move_to_string(this.game.current_iteration_best_move);
          console.log("selected move '" + str + "'");
          this.game.move(this.game.current_iteration_best_move.side, this.game.current_iteration_best_move.ndx);
          console.log(this.game.print_board());
          console.log("\n");
          response.write(str);
          if (this.is_game_over()) {
            return this.on_game_over(response);
          }
        }
        return response.end();
      }, this));
    };
    Server.prototype.is_game_over = function() {
      this.game.evaluator.evaluate();
      return this.game.evaluator.is_game_over();
    };
    Server.prototype.on_game_over = function(response) {
      var move;
      if (this.game.evaluator.winning_player === this.i_am) {
        console.log("I've won :-)");
        if (this.i_am === square.black) {
          this.won_as_black += 1;
        } else {
          this.won_as_white += 1;
        }
      } else {
        console.log("I've lost :-(");
        this.lost += 1;
        if (this.i_am === square.black) {
          this.lost_as_black += 1;
        } else {
          this.lost_as_white += 1;
        }
      }
      if (this.won_as_black + this.lost_as_black + this.won_as_white + this.lost_as_white === this.games_in_a_tournament) {
        response.write("Tournament over");
        response.end();
        console.log("Tournament over");
        this.log_tournament_results();
        return process.exit();
      } else {
        console.log("So far");
        this.log_tournament_results();
        console.log("Starting a new game");
        move = this.new_game();
        if (move) {
          response.write("new game, I've moved: " + (this.parser.move_to_string(move)));
        } else {
          response.write("new game, your turn");
        }
        return response.end();
      }
    };
    Server.prototype.log_tournament_results = function() {
      console.log(" * as black I've won " + this.won_as_black + " times and lost " + this.lost_as_black + " times!");
      return console.log(" * tas white I've won " + this.won_as_white + " times and lost " + this.lost_as_white + " times!");
    };
    return Server;
  })();
}).call(this);
