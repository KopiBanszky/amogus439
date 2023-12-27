"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const websocket_1 = require("../websocket");
function testIfGameEnd(game_id) {
    const sql = `SELECT * FROM Players WHERE game_id = ${game_id}`;
    export_db_connection_1.default.query(sql, (err, result) => {
        if (err) {
            console.error(err);
            return;
        }
        const players = result;
        let impostors = 0;
        let crewmates = 0;
        const impostors_list = []; // Initialize impostors_list as an empty array with type Player[]
        let task_done = 0;
        let task_total = 0;
        players.map((player) => {
            if (player.team)
                impostors_list.push(player); // Push player to impostors_list if player.team is true
            if (player.dead)
                return;
            if (player.team) {
                impostors++;
            }
            else {
                crewmates++;
                task_done += player.task_done.length;
                task_total += player.tasks.length;
            }
        });
        const isGameEnd = (impostors == 0 || crewmates <= impostors || task_done == task_total);
        if (isGameEnd) {
            if (impostors == 0 || task_done == task_total) {
                websocket_1.io.in(`Game_${game_id}`).emit('game_end', { code: 200, message: 'Crewmates won', impostors: impostors_list });
                return;
            }
            if (crewmates <= impostors) {
                websocket_1.io.in(`Game_${game_id}`).emit('game_end', { code: 201, message: 'Impostors won', impostors: impostors_list });
                return;
            }
        }
    });
}
exports.default = testIfGameEnd;
