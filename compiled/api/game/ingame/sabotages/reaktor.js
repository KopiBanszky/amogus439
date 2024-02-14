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
exports.reaktor = void 0;
const export_db_connection_1 = __importDefault(require("../../../../database/export_db_connection"));
const websocket_1 = require("../../websocket");
const count_down_1 = __importDefault(require("./count_down"));
function reaktor(sabotages, game_id, user_id) {
    return __awaiter(this, void 0, void 0, function* () {
        const connected = sabotages.find(sabotage => sabotage.type == 42);
        const ids = [];
        for (let index = 0; index < sabotages.length; index++) {
            const sabotage = sabotages[index];
            const result = yield new Promise((resolve, reject) => {
                export_db_connection_1.default.query(`INSERT INTO Game_sabotage SET triggerd = CURRENT_TIMESTAMP(), ?`, {
                    game_id: game_id,
                    sabotage_id: sabotage.SID == connected.SID ? connected.connect_id : sabotage.SID,
                    tag: 1
                }, (err, result) => {
                    if (err) {
                        console.error(err);
                        resolve(false);
                        return;
                    }
                    resolve(result);
                });
            });
            if (result == false)
                continue;
            ids.push(result.insertId);
            sabotages[index].game_sb_id = result.insertId;
        }
        websocket_1.io.to(`Game_${game_id}`).emit('sabotage_trigg', {
            type: "Reaktor",
            sabotage: sabotages
        });
        (0, count_down_1.default)(sabotages, game_id, ids);
    });
}
exports.reaktor = reaktor;
