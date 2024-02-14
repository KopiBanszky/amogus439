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
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
function isHost(gameId, userId) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => {
            export_db_connection_1.default.query(`SELECT host FROM Players WHERE id = ${userId} AND game_id = ${gameId}`, (err, result) => {
                if (err) {
                    console.error(err);
                    resolve(false);
                }
                else if (result.length == 0) {
                    resolve(false);
                }
                else
                    resolve(result[0].host);
            });
        });
    });
}
exports.default = isHost;
