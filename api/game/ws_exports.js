"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ws_join_1 = require("./join/ws_join");
const create_game_socket_1 = require("./host/create_game_socket");
const ws_disconnect_1 = __importDefault(require("./disconnect/ws_disconnect"));
const start_vote_1 = __importDefault(require("./ingame/start_vote"));
const vote_1 = __importDefault(require("./ingame/vote"));
const emergency_1 = __importDefault(require("./ingame/emergency"));
const task_done_1 = __importDefault(require("./ingame/task_done"));
const kill_1 = __importDefault(require("./ingame/kill"));
const report_1 = __importDefault(require("./ingame/report"));
exports.default = {
    create_new_player: ws_join_1.create_new_player,
    create_new_game: create_game_socket_1.create_new_game,
    disconnect: ws_disconnect_1.default,
    start_vote: start_vote_1.default,
    vote: vote_1.default,
    emergency: emergency_1.default,
    task_done: task_done_1.default,
    kill: kill_1.default,
    report: report_1.default
};
