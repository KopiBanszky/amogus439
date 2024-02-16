"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const websocket_1 = require("../websocket");
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const game_end_1 = __importDefault(require("./game_end"));
exports.default = (game_id, force_vote) => {
    export_db_connection_1.default.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND dead = 0`, (err, result) => {
        if (err) {
            console.error(err);
            return;
        }
        const players = result;
        let votes = 0;
        let noSkip = 0;
        //count the votes
        players.map((player) => {
            if (player.voted)
                votes++;
            noSkip += player.votes;
        });
        //check if all players voted or if the time is over, so force_vote is true
        if ((votes < players.length) && !force_vote)
            return;
        let skip = Math.round(votes / 2) >= noSkip; //check if skip is needed for sure
        let max = -1;
        let outVoted = players[0];
        let i = 0;
        //find the player with the most votes
        while (i < players.length) {
            console.log("Player votes:", players[i].votes);
            if (players[i].votes == max) {
                skip = true;
                console.log("0: skip");
            } //if there are more than one player with the most votes, skip
            if (players[i].votes > max) {
                max = players[i].votes;
                outVoted = players[i];
                skip = false;
            }
            i++;
        }
        // outVoted.geo_pos = JSON.parse(JSON.stringify(outVoted.geo_pos || {lat: 0, lon: 0}));
        //send the result to the players
        if (skip) {
            websocket_1.io.in(`Game_${game_id}`).emit('vote_result', { code: 200, message: 'Vote ended', skip: true, player: -1 });
        }
        else {
            websocket_1.io.in(`Game_${game_id}`).emit('vote_result', { code: 200, message: 'Vote ended', skip: false, player: outVoted });
            //set the player dead
            export_db_connection_1.default.query(`UPDATE Players SET dead = 1 WHERE id = ${outVoted.id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    return;
                }
                (0, game_end_1.default)(game_id, false);
            });
        }
        //reset the votes
        export_db_connection_1.default.query(`UPDATE Players SET voted = 0, votes = 0 WHERE game_id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                return;
            }
        });
        export_db_connection_1.default.query(`UPDATE Games SET status = 1 WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                return;
            }
        });
    });
};
