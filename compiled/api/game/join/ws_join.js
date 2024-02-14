"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.join_room = exports.create_new_player = void 0;
const websocket_1 = require("../websocket");
const utility_1 = require("../../../source/utility");
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
function update_players(game_id, player, socket_id, player_id) {
    websocket_1.io.in(`Game_${game_id}`).emit('update_players', { username: player.name, color: player.color, socket_id: socket_id, id: player_id });
}
function join_room(room, socket) {
    socket.join(room);
    console.log(`a user connected to ${room}`);
}
exports.join_room = join_room;
const create_new_player = {
    event: 'join_game',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const name = args.username;
        const gameStarted = new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT status FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('join_game', { code: 500, message: 'Internal server error' });
                resolve(true);
            }
            if (result.length == 0) {
                socket.emit('join_game', { code: 400, message: 'Game not found' });
                resolve(true);
            }
            if (result[0].status != 0) {
                socket.emit('join_game', { code: 403, message: 'Game already started' });
                resolve(true);
            }
            resolve(false);
        }));
        if (yield gameStarted)
            return;
        export_db_connection_1.default.query(`SELECT * FROM Players WHERE game_id = ${game_id}`, (err, players_res) => {
            if (err) {
                console.error(err);
                return;
            }
            for (let player of players_res) {
                if (player.name == name) {
                    socket.emit('join_game', { code: 401, message: 'Username already taken' });
                    return;
                }
            }
            ;
            let color = utility_1.COLORS[(0, utility_1.randomNum)(0, utility_1.COLORS.length - 1)];
            // players_res.map((player:Player) => {
            //     if(player.color == color){
            //         color = COLORS[randomNum(0, COLORS.length - 1)];
            //     }
            // });
            while (players_res.find((player) => player.color == color) || color == 0) {
                color = utility_1.COLORS[(0, utility_1.randomNum)(0, utility_1.COLORS.length - 1)];
            }
            export_db_connection_1.default.query(`INSERT INTO Players (game_id, socket_id, name, color, tasks, tasks_done) VALUES (${game_id}, '${socket.id}', '${name}', ${color}, '[]', '[]')`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit('join_game', { code: 500, message: 'Internal server error' });
                    return;
                }
                const player = {
                    id: result.insertId,
                    game_id: game_id,
                    socket_id: socket.id,
                    name: name,
                    color: color,
                    emergency: 0,
                    tasks: [],
                    tasks_done: [],
                    team: false,
                    geo_pos: { latitude: 0, longitude: 0 },
                    dead: false,
                    host: false,
                    votes: 0,
                    voted: false,
                };
                players_res.push(player);
                socket.emit('join_game', { code: 200, message: 'Joined successfully',
                    players: players_res,
                });
                join_room(`Game_${game_id}`, socket);
                update_players(game_id, player, socket.id, result.insertId);
            });
        });
    })
};
exports.create_new_player = create_new_player;
