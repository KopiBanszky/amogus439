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
const websocket_1 = require("../websocket");
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const report = {
    event: 'report',
    callback: (socket, data) => __awaiter(void 0, void 0, void 0, function* () {
        const { game_id, player_id, dead_id } = data;
        const game_prom = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', { code: 500, message: 'Error in database' });
                return;
            }
            ;
            if (result.length == 0) {
                resolve(null);
                socket.emit('report', { code: 404, message: 'Game not found' });
                return;
            }
            resolve(result[0]);
        }));
        if (game_prom == null)
            return;
        const game = game_prom;
        if (game.status != 1) {
            socket.emit('report', { code: 403, message: 'Game is not running' });
            return;
        }
        const player_prom = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE player_id = ${player_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', { code: 500, message: 'Error in database' });
                return;
            }
            ;
            if (result.length == 0) {
                resolve(null);
                socket.emit('report', { code: 404, message: 'Player not found' });
                return;
            }
            resolve(result[0]);
        }));
        if (player_prom == null)
            return;
        const player = player_prom;
        if (player.dead) {
            socket.emit('report', { code: 403, message: 'You are already dead' });
            return;
        }
        const deadPlayer_prom = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE player_id = ${dead_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', { code: 500, message: 'Error in database' });
                return;
            }
            ;
            if (result.length == 0) {
                resolve(null);
                socket.emit('report', { code: 404, message: 'Player not found' });
                return;
            }
            resolve(result[0]);
        }));
        if (deadPlayer_prom == null)
            return;
        const deadPlayer = deadPlayer_prom;
        if (!deadPlayer.dead) {
            socket.emit('report', { code: 403, message: 'Player is not dead' });
            return;
        }
        export_db_connection_1.default.query(`UPDATE Games SET status = 4 WHERE game_id = ${game_id}`, (err, result) => {
            if (err) {
                socket.emit('report', { code: 500, message: 'Error in database' });
                return;
            }
            socket.emit('report', { code: 200, message: 'Reported' });
            websocket_1.io.to(`Game_${game_id}`).emit('reported_player', { message: "Player reported", reporter: player, reported: deadPlayer });
        });
    })
};
exports.default = report;
