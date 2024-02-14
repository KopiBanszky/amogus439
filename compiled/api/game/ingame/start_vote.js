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
const isHost_1 = __importDefault(require("../host/isHost"));
const end_vote_1 = __importDefault(require("./end_vote"));
const start_vote = {
    event: 'start_vote',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const user_id = args.user_id;
        if (!(yield (0, isHost_1.default)(game_id, user_id))) {
            socket.emit('start_vote', { code: 403, message: 'You are not the host' });
            return;
        }
        //get vote time
        export_db_connection_1.default.query(`SELECT vote_time FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                return;
            }
            const vote_time = result[0].vote_time;
            //start vote
            //emit start_vote event and send vote_time
            websocket_1.io.in(`Game_${game_id}`).emit('start_vote', { code: 200, message: 'Voting started', vote_time: vote_time });
            //emit is first, then set game status to 2 (voting) to prevent players from voting before the event is emitted
            //set game status to 2 (voting)
            export_db_connection_1.default.query(`UPDATE Games SET status = 2 WHERE id = ${game_id}`, (err, updates) => {
                if (err) {
                    console.error(err);
                    return;
                }
                //close voting after vote_time seconds
                setTimeout(() => {
                    //set game status to 1 (ingame)
                    export_db_connection_1.default.query(`UPDATE Games SET status = 1 WHERE id = ${game_id}`, (err, updates) => {
                        if (err) {
                            console.error(err);
                            return;
                        }
                        //end vote, it has to be second because the game status has to be 1 (ingame) to prevent players from voting after the event is emitted
                        (0, end_vote_1.default)(game_id, true);
                    });
                }, vote_time * 1000);
            });
        });
    })
};
exports.default = start_vote;
