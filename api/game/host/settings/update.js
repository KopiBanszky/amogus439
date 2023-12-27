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
const isHost_1 = __importDefault(require("../isHost"));
exports.default = {
    path: '/api/game/host/settings/update',
    method: 'PUT',
    handler: function (req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const options = ["task_num", "task_visibility", "vote_time", "anonymus_vote", "kill_cooldown", "impostor_max", "emergencies", "map"];
            const { game_id, user_id } = req.body;
            if (!(yield (0, isHost_1.default)(game_id, user_id))) {
                res.status(403).send({
                    message: 'You are not the host of this game'
                });
                return 403;
            }
            let sqlVariables = "";
            let x = 0;
            const bodyKeys = Object.keys(req.body);
            for (let i of bodyKeys) {
                if (!options.includes(i))
                    continue;
                if (i == "map")
                    req.body[i] = `'${req.body[i]}'`;
                sqlVariables += `${i} = ${req.body[i]}${x == bodyKeys.length - 2 ? "" : ","} `;
                ++x;
            }
            const sql = `UPDATE Games SET ${sqlVariables} WHERE id = ${game_id}`;
            export_db_connection_1.default.query(sql, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(500).send({
                        message: 'Internal server error',
                    });
                    return 500;
                }
                ;
                res.status(200).send({
                    message: 'Game settings updated successfully'
                });
                return 200;
            });
        });
    }
};
