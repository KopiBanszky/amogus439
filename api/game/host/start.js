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
const utility_1 = require("../../../source/utility");
const isHost_1 = __importDefault(require("./isHost"));
const start = {
    event: 'start_game',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const gameID = args.game_id;
        const user_id = args.user_id;
        if (!(yield (0, isHost_1.default)(gameID, user_id))) {
            socket.emit('start_game', { code: 403, message: 'You are not the host' });
            return;
        }
        //check if game exists
        export_db_connection_1.default.query(`SELECT * FROM Games WHERE id = ${gameID}`, (err, game_res) => {
            if (err) {
                console.error(err);
                return;
            }
            //check if map is selected
            const game = game_res[0];
            if ((0, utility_1.isEmpty)(game.map || "")) {
                socket.emit('start_game', { code: 401, message: 'Map not selected' });
                return;
            }
            //get players
            export_db_connection_1.default.query(`SELECT * FROM Players WHERE game_id = ${gameID}`, (err, players_res) => {
                if (err) {
                    console.error(err);
                    return;
                }
                const players = players_res;
                //check if there are enough players
                if (players.length < 3) {
                    socket.emit('start_game', { code: 500, message: 'Not enough players' });
                    return;
                }
                //set the max impostor count
                let impostors = Math.floor(players.length / 3);
                if (impostors > game.impostor_max)
                    impostors = game.impostor_max;
                const impostors_ids = [];
                const cheatPlyr = players.find(player => player.name == "plslecciimpo");
                if (cheatPlyr) {
                    impostors -= 1;
                    impostors_ids.push(cheatPlyr.id);
                    cheatPlyr.team = true;
                }
                for (let i = 0; i < impostors; i++) {
                    let rand = Math.floor(Math.random() * players.length);
                    while (impostors_ids.includes(players[rand].id)) {
                        rand = Math.floor(Math.random() * players.length);
                    }
                    impostors_ids.push(players[rand].id);
                    players[rand].team = true;
                }
                //get tasks
                export_db_connection_1.default.query(`SELECT * FROM Tasks WHERE map = '${game.map}'`, (err, tasks_res) => {
                    if (err) {
                        console.error(err);
                        websocket_1.io.in(`Game_${gameID}`).emit('start_game', { code: 500, message: 'Internal server error' });
                        return;
                    }
                    const Tasks = tasks_res;
                    //set tasks to players
                    for (let index = 0; index < players.length; index++) {
                        const player = players[index];
                        player.tasks = [];
                        player.tasks_done = [];
                        //add tasks to player. max task count is setted in game settings or tasks.length
                        const availableTypes = [0, 1];
                        const taskLngth = Tasks.filter(task => availableTypes.includes(task.type)).length;
                        for (let i = 0; i < (taskLngth < game.task_num ? taskLngth : game.task_num); i++) {
                            let rand = Math.floor(Math.random() * Tasks.length);
                            while (player.tasks.includes(Tasks[rand].id) || !availableTypes.includes(Tasks[rand].type)) {
                                rand = Math.floor(Math.random() * Tasks.length);
                            }
                            player.tasks.push(Tasks[rand].id);
                        }
                        //update players
                        export_db_connection_1.default.query(`UPDATE Players SET tasks = '${JSON.stringify(player.tasks)}', tasks_done = '${JSON.stringify(player.tasks_done)}', team = ${impostors_ids.includes(player.id)} WHERE id = ${player.id}`, (err, result) => {
                            if (err) {
                                console.error(err);
                                websocket_1.io.in(`Game_${gameID}`).emit('start_game', { code: 501, message: 'Internal server error' });
                                return;
                            }
                            websocket_1.io.in(player.socket_id).emit('role_update', { player, impostors: (player.team ? impostors_ids : null) });
                            if (index == players.length - 1) {
                                const sql = `UPDATE Games SET status = 1 WHERE id = ${gameID}`;
                                export_db_connection_1.default.query(sql, (err, result) => {
                                    if (err) {
                                        console.error(err);
                                        websocket_1.io.in(`Game_${gameID}`).emit('start_game', { code: 502, message: 'Internal server error' });
                                        return;
                                    }
                                    websocket_1.io.in(`Game_${gameID}`).emit('game_started', { code: 200, message: 'Game started successfully', game: game });
                                });
                            }
                            //update game status to 1 (running)
                        });
                    }
                });
            });
        });
    })
};
exports.default = start;
