import { io } from '../websocket';
import db from '../../../database/export_db_connection';
import { Player } from '../../../source/utility';
import end_vote from './end_vote';

const vote = {
    event: 'vote',
    callback: async (args:any, socket:any) => {
        const game_id:number = args.game_id;
        const user_id:number = args.user_id;
        const vote_id:number = args.vote_id; //player id to vote for, -1 to skip

        //check if voting is enabled
        const isVoting:any = await new Promise((resolve, reject) => db.query(`SELECT status, anonymus_vote FROM Games WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                resolve(false);
            }
            if(result.length == 0){
                socket.emit('vote', {code: 403, message: 'Game not found'});
                resolve(false);
            }
            if(result[0].status != 2){
                socket.emit('vote', {code: 403, message: 'Game not in voting phase'});
                resolve(false);
            }
            resolve(result[0]);
        }));
        if(isVoting == false) return;

        //get only alive players
        db.query(`SELECT * FROM Players WHERE dead = 0 AND game_id = ${game_id}`, async (err, result) => {
            if(err){
                console.error(err);
                return;
            }
            if(result.length == 0){
                socket.emit('vote', {code: 403, message: 'Game not found'});
                return;
            }
            const players:Player[] = result;
            //check if player is in the game and alive
            if(!players.map((player:Player) => player.id).includes(user_id)){
                socket.emit('vote', {code: 403, message: 'You are not in this game or you are dead'});
                return;
            }

            //find the pleayer who voted
            const playerWhoVote:Player|undefined = players.find((player: Player) => player.id === user_id);
            if (playerWhoVote) {
                //check if player already voted
                if(playerWhoVote.voted){
                    socket.emit('vote', {code: 403, message: 'You already voted'});
                    return;
                }
                //set voted to true
                playerWhoVote.voted = true;
            }

            //find the player to vote for
            const playerToVote:Player|undefined = players.find((player: Player) => player.id === vote_id);
            if (playerToVote) {
                //add a vote to the player
                playerToVote.votes++;
            }

            //check if anonymous vote is enabled
            console.log(isVoting);
            const anonymous_vote:boolean = isVoting.anonymous_vote == 1;


            db.query(`UPDATE Players SET voted = 1 WHERE id = ${user_id}`, (err, result) => {
                if(err){
                    console.error(err);
                    return;
                }
            });
            db.query(`UPDATE Players SET votes = ${playerToVote?.votes||1} WHERE id = ${vote_id}`, (err, result) => {
                if(err){
                    console.error(err);
                    return;
                }
            });
            //send the vote to the players
            socket.emit('vote', {code: 200, message: 'Voted successfully'});
            io.in(`Game_${game_id}`).emit('vote_placed', {code: 200, message: 'Voted successfully', voter: (anonymous_vote ? playerWhoVote : -1), voted: playerToVote||-1});

            //check if all players voted
            end_vote(game_id, false);
        });
    }
}

export default vote;