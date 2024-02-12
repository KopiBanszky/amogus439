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
const end_vote_1 = __importDefault(require("./end_vote"));
const vote = {
    event: 'vote',
    callback: (args, socket) => __awaiter(void 0, void 0, void 0, function* () {
        const game_id = args.game_id;
        const user_id = args.user_id;
        const vote_id = args.vote_id; //player id to vote for, -1 to skip
        //check if voting is enabled
        const isVoting = yield new Promise((resolve, reject) => export_db_connection_1.default.query(`SELECT status, anonymus_vote FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('vote', { code: 403, message: 'Game not found' });
                resolve(false);
            }
            if (result[0].status != 2) {
                socket.emit('vote', { code: 403, message: 'Game not in voting phase' });
                resolve(false);
            }
            resolve(result[0]);
        }));
        if (isVoting == false)
            return;
        //get only alive players
        export_db_connection_1.default.query(`SELECT * FROM Players WHERE dead = 0 AND game_id = ${game_id}`, (err, result) => __awaiter(void 0, void 0, void 0, function* () {
            if (err) {
                console.error(err);
                return;
            }
            if (result.length == 0) {
                socket.emit('vote', { code: 403, message: 'Game not found' });
                return;
            }
            const players = result;
            //check if player is in the game and alive
            if (!players.map((player) => player.id).includes(user_id)) {
                socket.emit('vote', { code: 403, message: 'You are not in this game or you are dead' });
                return;
            }
            //find the pleayer who voted
            const playerWhoVote = players.find((player) => player.id === user_id);
            if (playerWhoVote) {
                //check if player already voted
                if (playerWhoVote.voted) {
                    socket.emit('vote', { code: 403, message: 'You already voted' });
                    return;
                }
                //set voted to true
                playerWhoVote.voted = true;
            }
            //find the player to vote for
            const playerToVote = players.find((player) => player.id === vote_id);
            if (playerToVote) {
                //add a vote to the player
                playerToVote.votes++;
            }
            //check if anonymous vote is enabled
            const anonymous_vote = (isVoting.anonymus_vote == 1);
            export_db_connection_1.default.query(`UPDATE Players SET voted = 1 WHERE id = ${user_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    return;
                }
            });
            export_db_connection_1.default.query(`UPDATE Players SET votes = ${(playerToVote === null || playerToVote === void 0 ? void 0 : playerToVote.votes) || 1} WHERE id = ${vote_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    return;
                }
            });
            //send the vote to the players
            socket.emit('vote', { code: 200, message: 'Voted successfully' });
            websocket_1.io.in(`Game_${game_id}`).emit('vote_placed', { code: 200, message: 'Voted successfully', voter: (anonymous_vote ? playerWhoVote : -1), voted: playerToVote || -1 });
            //check if all players voted
            (0, end_vote_1.default)(game_id, false);
        }));
    })
};
exports.default = vote;
