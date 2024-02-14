"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.simple_sabotage = void 0;
const export_db_connection_1 = __importDefault(require("../../../../database/export_db_connection"));
const websocket_1 = require("../../websocket");
function simple_sabotage(sabotage, game_id, user_id) {
    export_db_connection_1.default.query(`INSERT INTO Game_sabotage SET triggerd = CURRENT_TIMESTAMP(), ?`, {
        game_id: game_id,
        sabotage_id: sabotage.SID,
        tag: 1
    }, (err, result) => {
        if (err) {
            console.error(err);
            return;
        }
        sabotage.game_sb_id = result.insertId;
        websocket_1.io.in(`Game_${game_id}`).emit('sabotage_trigg', {
            type: sabotage.name,
            sabotage: sabotage
        });
    });
}
exports.simple_sabotage = simple_sabotage;
