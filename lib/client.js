(function() {
  var Client, Game, MoveParser, http, max_value, square, square_sides, util;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Game = require('game');
  MoveParser = require('move_parser');
  square = require('square').square;
  square_sides = require('square').square_sides;
  max_value = require('square').max_value;
  util = require('util');
  http = require('http');
  module.exports = Client = (function() {
    function Client(n) {
      this.n = n;
      this.parser = new MoveParser(this.n);
      this.game = new Game(this.n);
      this.first_move = true;
    }
    Client.prototype.play_game = function() {
      var my_move, req, server_move;
      my_move = null;
      if (this.first_move) {
        my_move = {
          side: 'left',
          ndx: Math.floor(Math.random() * this.n)
        };
        console.log("making the first move");
        this.first_move = false;
      } else {
        console.log("Thinking ...");
        this.game.iterative_deepening(5);
        my_move = this.game.current_iteration_best_move;
      }
      console.log("selected move '" + (this.parser.move_to_string(my_move)) + "'");
      this.game.move(my_move.side, my_move.ndx);
      console.log(this.game.print_board());
      console.log("\n");
      server_move = [];
      req = http.request({
        host: '127.0.0.1',
        port: 9090,
        method: 'POST',
        path: '/'
      }, __bind(function(res) {
        res.on('data', __bind(function(chunk) {
          return server_move.push(chunk);
        }, this));
        return res.on('end', __bind(function() {
          return this.handle_server_reply(server_move.join());
        }, this));
      }, this));
      req.write(this.parser.move_to_string(my_move));
      req.end();
      return true;
    };
    Client.prototype.handle_server_reply = function(body) {
      var move, play_game_latter;
      if (body.match(/Tournament/)) {
        console.log("Tournament over");
        process.exit(0);
      }
      if (body.match(/^\s*(top|bottom|right|left)\s*/)) {
        move = this.parser.string_to_move(body);
        console.log("got move '" + (this.parser.move_to_string(move)) + "'");
        this.game.move(move.side, move.ndx);
        console.log(this.game.print_board());
        console.log("\n");
        body = body.replace(this.parser.move_to_string(move));
      }
      if ((this.is_game_over() && !body.match(/new game/)) || (!this.is_game_over() && body.match(/new game/))) {
        console.log("I'm out of sync with the server, aborting");
        process.exit(0);
      }
      if (body.match(/new game/)) {
        console.log("Game over");
        this.game = new Game(this.n);
        if (body.match(/your turn/)) {
          this.first_move = true;
          console.log("My turn");
        } else {
          move = this.parser.string_to_move(body);
          console.log("Server starts with new move: " + (this.parser.move_to_string(move)));
          this.game.move(move.side, move.ndx);
          console.log(this.game.print_board());
          console.log("\n");
        }
      }
      play_game_latter = __bind(function() {
        return this.play_game();
      }, this);
      setTimeout(play_game_latter, 200);
      return true;
    };
    Client.prototype.is_game_over = function() {
      this.game.evaluator.evaluate();
      return this.game.evaluator.is_game_over();
    };
    return Client;
  })();
}).call(this);
