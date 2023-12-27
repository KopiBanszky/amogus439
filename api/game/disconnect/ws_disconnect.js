"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const websocket_1 = require("../websocket");
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const disconnect = {
    event: 'disconnect',
    callback: (args, socket) => {
        const get_plyr_sql = `SELECT * FROM Players WHERE socket_id = '${socket.id}'`;
        export_db_connection_1.default.query(get_plyr_sql, (err, plyr) => {
            if (err) {
                console.error(err);
                return;
            }
            if (plyr.length == 0)
                return;
            const sql = `DELETE FROM Players WHERE socket_id = '${socket.id}'`;
            export_db_connection_1.default.query(sql, (err, result) => {
                if (err) {
                    console.error(err);
                    return;
                }
                websocket_1.io.in(`Game_${plyr[0].game_id}`).emit('player_disconnected', { id: plyr[0].id, socket_id: socket.id, username: plyr[0].name });
            });
        });
    }
};
exports.default = disconnect;
