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
const game_end_1 = __importDefault(require("./game_end"));
const kill = {
    event: 'kill',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const user_id = args.user_id;
        const target_id = args.target_id;
        //check if game exists
        const game_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('kill', { code: 500, message: 'Internal server error' });
                resolve({});
            }
            if (result.length == 0) {
                socket.emit('kill', { code: 403, message: 'Game not found' });
                resolve({});
            }
            resolve(result[0]);
        }));
        if (Object.keys(game_promise).length == 0)
            return;
        const game = game_promise;
        if (game.status != 1) {
            socket.emit('kill', { code: 403, message: 'Game not in progress' });
            return;
        }
        //check if player is in the game and alive
        const player_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id} AND dead = 0`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('kill', { code: 500, message: 'Internal server error' });
                resolve(null);
            }
            if (result.length == 0) {
                socket.emit('kill', { code: 403, message: 'You are not in this game or you are dead' });
                resolve(null);
            }
            resolve(result[0]);
        }));
        if (player_promise == null)
            return;
        const player = player_promise;
        //check if target is in the game and alive
        const target_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE id = ${target_id} AND game_id = ${game_id} AND dead = 0`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('kill', { code: 500, message: 'Internal server error' });
                resolve(null);
            }
            if (result.length == 0) {
                socket.emit('kill', { code: 403, message: 'Target not found' });
                resolve(null);
            }
            resolve(result[0]);
        }));
        if (target_promise == null)
            return;
        const target = target_promise;
        //check if player is impostor
        if (!player.team) {
            socket.emit('kill', { code: 403, message: 'You are not an impostor' });
            return;
        }
        //check if target is impostor
        if (target.team) {
            socket.emit('kill', { code: 403, message: 'Target is an impostor' });
            return;
        }
        export_db_connection_1.default.query(`UPDATE Players SET dead = 1 WHERE id = ${target_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('kill', { code: 500, message: 'Internal server error' });
                return;
            }
            socket.emit('kill', { code: 200, message: 'Killed successfully' });
            websocket_1.io.in(target.socket_id).emit('got_killed', { player });
            (0, game_end_1.default)(game_id);
        });
    })
};
exports.default = kill;
