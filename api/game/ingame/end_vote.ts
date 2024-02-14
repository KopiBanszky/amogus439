import { io } from "../websocket";
import db from "../../../database/export_db_connection";
import { Player } from "../../../source/utility";
import testIfGameEnd from "./game_end";

export default (game_id:number, force_vote:boolean) => {
    db.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND dead = 0`, (err, result) => {
        if(err){
            console.error(err);
            return;
        }
        const players:Player[] = result;


        let votes:number = 0;
        let noSkip:number = 0;

        //count the votes
        players.map((player:Player) => {
            if(player.voted) votes++;   
            noSkip += player.votes;
        });


        //check if all players voted or if the time is over, so force_vote is true
        if((votes < players.length) && !force_vote) return;


        let skip:boolean = Math.round(votes/2) >= noSkip; //check if skip is needed for sure
        let max:number = -1;
        let outVoted:Player = players[0];
        let i:number = 0;

        //find the player with the most votes
        while(i<players.length){
            console.log("Player votes:", players[i].votes);
            if(players[i].votes == max) {
                skip = true;
                console.log("0: skip");
            } //if there are more than one player with the most votes, skip
            if(players[i].votes > max){
                max = players[i].votes;
                outVoted = players[i];
                skip = false;
            }
            i++;
        }

        // outVoted.geo_pos = JSON.parse(JSON.stringify(outVoted.geo_pos || {lat: 0, lon: 0}));

        //send the result to the players
        if(skip){
            io.in(`Game_${game_id}`).emit('vote_result', {code: 200, message: 'Vote ended', skip: true, player: -1});
        }
        else{
            io.in(`Game_${game_id}`).emit('vote_result', {code: 200, message: 'Vote ended', skip: false, player: outVoted});
            //set the player dead
            db.query(`UPDATE Players SET dead = 1 WHERE id = ${outVoted.id}`, (err, result) => {
                if(err){
                    console.error(err);
                    return;
                }
                testIfGameEnd(game_id, false);
            });
        }
        //reset the votes
        db.query(`UPDATE Players SET voted = 0, votes = 0 WHERE game_id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                return;
            }
        });
        db.query(`UPDATE Games SET status = 1 WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                return;
            }
        });
    });
}
