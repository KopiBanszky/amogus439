"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.create_new_game = void 0;
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const ws_join_1 = require("../join/ws_join");
const utility_1 = require("../../../source/utility");
const create_new_game = {
    event: 'create_game',
    callback: (args, socket) => {
        const game_id = args.game_id;
        const username = args.username;
        if ((0, utility_1.isEmpty)(username) || (game_id == undefined || game_id == null)) {
            socket.emit('create_game', { code: 400, message: 'Values cannot be empty' });
            return;
        }
        const sql = `SELECT * FROM Games WHERE id = ${game_id}`;
        export_db_connection_1.default.query(sql, (err, game) => {
            if (err) {
                console.error(err);
                socket.emit('create_game', { code: 500, message: 'Internal server error' });
                return;
            }
            if (game.length == 0) {
                socket.emit('create_game', { code: 400, message: 'Game does not exist' });
                return;
            }
            const insertplayer_sql = `INSERT INTO Players (game_id, socket_id, name, color, host) VALUES (${game_id}, '${socket.id}', '${username}', 0, 1)`;
            export_db_connection_1.default.query(insertplayer_sql, (err, player_res) => {
                if (err) {
                    console.error(err);
                    socket.emit('create_game', { code: 500, message: 'Internal server error' });
                    return;
                }
                socket.emit('create_game', {
                    code: 200,
                    message: 'Game created successfully',
                    data: {
                        game: game[0],
                        player: {
                            id: player_res.insertId,
                            game_id: game_id,
                            socket_id: socket.id,
                            name: username,
                            color: 0,
                            emergency: 0,
                            tasks: [],
                            task_done: [],
                            team: true,
                            geo_pos: { latitude: 0, longitude: 0 },
                            dead: false,
                            host: true,
                            votes: 0,
                            voted: false,
                        }
                    }
                });
                (0, ws_join_1.join_room)(`Game_${game_id}`, socket);
            });
        });
    }
};
exports.create_new_game = create_new_game;
