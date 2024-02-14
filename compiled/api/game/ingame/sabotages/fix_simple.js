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
const websocket_1 = require("../../websocket");
exports.default = {
    event: 'fix_simple',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const { game_id, user_id, sabotage_id, name } = args;
        if (game_id == undefined || game_id == null || user_id == undefined || user_id == null) {
            socket.emit("fix_simple", {
                code: 400,
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const player_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND id = ${user_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("fix_simple", {
                        code: 502,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    socket.emit("fix_simple", {
                        code: 404,
                        message: 'Player not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });
        if (player_promise == false)
            return;
        const player = player_promise;
        const game_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("fix_simple", {
                        code: 501,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 501;
                }
                if (result.length == 0) {
                    socket.emit("fix_simple", {
                        code: 404,
                        message: 'Game not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });
        if (game_promise == false)
            return;
        const game = game_promise;
        if (game.status != 1) {
            socket.emit("fix_simple", {
                code: 403,
                message: 'Game not in progress'
            });
            return 403;
        }
        const sabotage_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Game_sabotage WHERE id = ${sabotage_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("fix_simple", {
                        code: 500,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    socket.emit("fix_simple", {
                        code: 404,
                        message: 'Sabotage not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });
        if (sabotage_promise == false)
            return;
        const sabotage = sabotage_promise;
        if (sabotage.tag == -1) {
            socket.emit("fix_simple", {
                code: 403,
                message: 'Sabotage already fixed'
            });
            return 403;
        }
        export_db_connection_1.default.query(`UPDATE Game_sabotage SET tag = -1, triggerd = CURRENT_TIMESTAMP() WHERE id = ${sabotage_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit("fix_simple", {
                    code: 500,
                    message: 'Internal server error',
                });
                return 500;
            }
            socket.emit("fix_simple", {
                code: 200,
                message: 'Sabotage fixed successfully'
            });
            websocket_1.io.to(`Game_${game_id}`).emit('sabotage_fixed', {
                sabotage_id: sabotage_id,
                type: name
            });
        });
    })
};
