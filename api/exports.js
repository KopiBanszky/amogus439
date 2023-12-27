"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const task_upload_1 = __importDefault(require("./manager/task_upload"));
const get_tasks_1 = __importDefault(require("./manager/get_tasks"));
const delete_task_1 = __importDefault(require("./manager/delete_task"));
const join_game_1 = __importDefault(require("./game/join/join_game"));
const create_game_1 = __importDefault(require("./game/host/create_game"));
const update_1 = __importDefault(require("./game/host/settings/update"));
const maps_1 = __importDefault(require("./manager/maps"));
exports.default = {
    task_upload: task_upload_1.default,
    get_tasks: get_tasks_1.default,
    delete_task: delete_task_1.default,
    join_game: join_game_1.default,
    create_game: create_game_1.default,
    update: update_1.default,
    maps: maps_1.default
};
