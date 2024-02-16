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
const game_end_1 = __importDefault(require("../game_end"));
function check_cooldown(ids, game_id, time) {
    return __awaiter(this, void 0, void 0, function* () {
        const results = yield new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT * FROM Game_sabotage WHERE id = ${ids[0]} OR id = ${ids[1]}`, (err, result) => {
                if (err) {
                    console.error(err);
                    resolve(false);
                    return;
                }
                resolve(result);
                export_db_connection_1.default.query(`UPDATE Game_sabotage SET tag = 1 WHERE id = ${ids[0]} OR id = ${ids[1]}`, (err, result) => {
                    if (err) {
                        console.error(err);
                        return;
                    }
                });
            });
        });
        if (results.length != 2) {
            return 400; //sabotage not found
        }
        const now = new Date().getTime();
        const trigger1 = new Date(results[0].triggerd).getTime();
        const trigger2 = new Date(results[1].triggerd).getTime();
        // console.log(trigger1, trigger2, now, time * 1000);
        // console.log(trigger1 - now, now - trigger2, time * 1000);
        if (
        //fix: added new Date() to results
        ((now - trigger1) > ((time + 4) * 1000)) ||
            ((now - trigger2) > ((time + 4) * 1000))) {
            return 203; //dead
        }
        if (results[0].tag == 2 && results[1].tag == 2) {
            return 202; //fixed
        }
        return 201; //cooldown
    });
}
function default_1(sabotages, game_id, insertedIDS) {
    let time = sabotages[0].time;
    const interval = setInterval(() => __awaiter(this, void 0, void 0, function* () {
        const result = yield check_cooldown(insertedIDS, game_id, sabotages[0].time);
        if (result == 201) {
            return;
        }
        export_db_connection_1.default.query(`UPDATE Game_sabotage SET tag = -1, triggerd = CURRENT_TIMESTAMP() WHERE id = ${insertedIDS[0]} OR id = ${insertedIDS[1]}`, (err, result) => {
            if (err) {
                console.error(err);
                return;
            }
        });
        // time -= 1;
        // if(time > 0) return;
        if (result == 202) {
            websocket_1.io.to(`Game_${game_id}`).emit('sabotage_fixed', {
                type: "Reaktor",
                sabotages: sabotages
            });
        }
        if (result == 203) {
            (0, game_end_1.default)(game_id, true);
        }
        if (result == 202 || result == 203 || result == 400) {
            clearInterval(interval);
        }
    }), 1000);
}
exports.default = default_1;
