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
const task_done = {
    event: 'task_done',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const user_id = args.user_id;
        const task_id = args.task_id;
        const task_code = args.task_code;
        //check if game exists
        const game_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('task_done', { code: 500, message: 'Internal server error' });
                resolve({});
            }
            if (result.length == 0) {
                socket.emit('task_done', { code: 403, message: 'Game not found' });
                resolve({});
            }
            resolve(result[0]);
        }));
        if (Object.keys(game_promise).length == 0)
            return;
        const game = game_promise;
        if (game.status != 1) {
            socket.emit('task_done', { code: 403, message: 'Game not in progress' });
            return;
        }
        //check if player is in the game and alive
        const player_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('task_done', { code: 500, message: 'Internal server error' });
                resolve(null);
            }
            if (result.length == 0) {
                socket.emit('task_done', { code: 403, message: 'You are not in this game' });
                resolve(null);
            }
            resolve(result[0]);
        }));
        if (player_promise == null)
            return;
        const player = player_promise;
        if (player.team) {
            socket.emit('task_done', { code: 205, message: 'You are an impostor, the task does not count', id: task_id });
            return;
        }
        //check if task exists
        const task_promise = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT * FROM Tasks WHERE id = ${task_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('task_done', { code: 500, message: 'Internal server error' });
                resolve(null);
            }
            if (result.length == 0) {
                socket.emit('task_done', { code: 403, message: 'Task not found' });
                resolve(null);
            }
            resolve(result[0]);
        }));
        if (task_promise == null)
            return;
        const task = task_promise;
        if (task.code != task_code) {
            socket.emit('task_done', { code: 402, message: 'Helytelen kód' });
            return;
        }
        if (task.type == 1) {
            export_db_connection_1.default.query(`SELECT * FROM Tasks WHERE connect_id = ${task.id}`, (err, result) => {
                result[0].geo_pos = JSON.parse(result[0].geo_pos);
                socket.emit('task_done', { code: 203, message: 'Ez egy kettős task, meg kell csinálnod a másikat is', id: task.id, new_task: result[0] });
            });
            return;
        }
        player.tasks_done = JSON.parse(player.tasks_done.toString() || JSON.stringify([]));
        //check if task is already done
        if (player.tasks_done.includes(task_id)) {
            socket.emit('task_done', { code: 403, message: 'Task already done' });
            return;
        }
        //set task as done
        player.tasks_done.push(task_id);
        export_db_connection_1.default.query(`UPDATE Players SET tasks_done = '${JSON.stringify(player.tasks_done)}' WHERE id = ${player.id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('task_done', { code: 500, message: 'Internal server error' });
                return;
            }
            socket.emit('task_done', { code: 200, message: 'Task done', id: task_id });
            console.log(game.task_visibility, game_id);
            if (game.task_visibility)
                websocket_1.io.in(`Game_${game_id}`).emit('task_done_by_crew', { player_id: player.id, task_id: task_id });
            (0, game_end_1.default)(game_id, false);
        });
    })
};
exports.default = task_done;
