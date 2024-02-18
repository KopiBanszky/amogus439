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
const simple_sabotage_1 = require("./simple_sabotage");
const reaktor_1 = require("./reaktor");
const constant_settings_1 = require("../../../manager/constant_settings");
exports.default = {
    event: 'sabotage',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const { game_id, user_id, sabotage } = args;
        if (game_id == undefined || game_id == null || user_id == undefined || user_id == null || sabotage == undefined || sabotage == null) {
            socket.emit("sabotage", {
                code: 400,
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const player_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND id = ${user_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("sabotage", {
                        code: 501,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    socket.emit("sabotage", {
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
        if (!player.team) {
            socket.emit("sabotage", {
                code: 403,
                message: 'You are not an impostor'
            });
            return 403;
        }
        const game_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("sabotage", {
                        code: 501,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    socket.emit("sabotage", {
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
        if (game_promise.status != 1) {
            socket.emit("sabotage", {
                code: 403,
                message: 'Game not in progress'
            });
            return 403;
        }
        const game = game_promise;
        const sabotage_promise = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT *, Sabotages.id AS SID FROM Sabotages INNER JOIN Tasks ON (Sabotages.task_id = Tasks.id) WHERE name = '${sabotage}' AND map = '${game.map}'`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("sabotage", {
                        code: 502,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    socket.emit("sabotage", {
                        code: 404,
                        message: 'Sabotage not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result);
            });
        });
        if (sabotage_promise == false)
            return;
        const allowed = yield new Promise((resolve, result) => {
            export_db_connection_1.default.query(`SELECT * FROM Game_sabotage WHERE game_id = ${game_id} ORDER BY id DESC`, (err, result) => {
                if (err) {
                    console.error(err);
                    socket.emit("sabotage", {
                        code: 503,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                for (let index = 0; index < result.length; index++) {
                    const element = result[index];
                    if (element.tag > 0) {
                        socket.emit("sabotage", {
                            code: 403,
                            message: 'Sabotage already triggered'
                        });
                        resolve(false);
                        return 403;
                    }
                    // if (element.tag == -1) {
                    //     const time = new Date(element.triggerd);
                    //     const current_time = new Date();
                    //     const COOLDOWN = constant_settings_1.settings.sabotage_coolwown * 1000;
                    //     console.log(current_time.getTime() - time.getTime());
                    //     if (current_time.getTime() - time.getTime() < COOLDOWN) {
                    //         socket.emit("sabotage", {
                    //             code: 403,
                    //             message: 'Sabotage is on cooldown'
                    //         });
                    //         resolve(false);
                    //         return 403;
                    //     }
                    // }
                }
                resolve(true);
                return 200;
            });
        });
        if (allowed == false)
            return;
        if (sabotage === 'Reaktor') {
            (0, reaktor_1.reaktor)(sabotage_promise, game_id, user_id);
        }
        else if (sabotage === 'Lights') {
            (0, simple_sabotage_1.simple_sabotage)(sabotage_promise[0], game_id, user_id);
        }
        else if (sabotage === 'Navigation') {
            ;
            (0, simple_sabotage_1.simple_sabotage)(sabotage_promise[0], game_id, user_id);
        }
        else {
            socket.emit("sabotage", {
                code: 404,
                message: 'Sabotage not found'
            });
            return;
        }
        socket.emit("sabotage", {
            code: 200,
            message: 'Sabotage triggered'
        });
    })
};
