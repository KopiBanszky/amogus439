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
const export_db_connection_1 = __importDefault(require("../../../../database/export_db_connection"));
const reaktorfix = {
    event: 'reaktorfix',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const user_id = args.user_id;
        const game_sb_id = args.game_sb_id;
        //check if game exists
        const game_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 500, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'Game not found' });
                resolve(false);
            }
            resolve(result[0]);
        }));
        if (game_promise == false)
            return;
        const game = game_promise;
        if (game.status != 1) {
            socket.emit('reaktorfix', { code: 403, message: 'Game not in progress' });
            return;
        }
        //check if player is in the game and alive
        const player_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 501, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'You are not in this game' });
                resolve(false);
            }
            resolve(result[0]);
        }));
        if (player_promise == false)
            return;
        const player = player_promise;
        if (player.dead) {
            socket.emit('reaktorfix', { code: 403, message: 'You are dead' });
            return;
        }
        //check if sabotage exists
        const sabotage_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Game_sabotage WHERE id = ${game_sb_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 502, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'Sabotage not found' });
                resolve(false);
            }
            resolve(result[0]);
        }));
        if (sabotage_promise == false)
            return;
        const sabotage = sabotage_promise;
        if (sabotage.tag == -1) {
            socket.emit('reaktorfix', { code: 403, message: 'Sabotage fixed' });
            return;
        }
        //update sabotage
        export_db_connection_1.default.query(`UPDATE Game_sabotage SET tag = 2 WHERE id = ${game_sb_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 500, message: 'Internal server error' });
                return;
            }
            socket.emit('reaktorfix', { code: 200, message: 'Holding...' });
        });
    })
};
exports.default = reaktorfix;
