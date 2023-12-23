import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import isHost from '../host/isHost';
import end_vote from './end_vote';

const start_vote = {
    event: 'start_vote',
    callback: async (args:any, socket:any) => {
        const game_id = args.game_id;
        const user_id = args.user_id;

        if(!await isHost(game_id, user_id)){
            socket.emit('start_vote', {code: 403, message: 'You are not the host'});
            return;
        }
        //get vote time
        db.query(`SELECT vote_time FROM Games WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                return;
            }
            const vote_time:number = result[0].vote_time;
            //start vote
            //emit start_vote event and send vote_time
            io.in(`Game_${game_id}`).emit('start_vote', {code: 200, message: 'Voting started', vote_time: vote_time});
            //emit is first, then set game status to 2 (voting) to prevent players from voting before the event is emitted
            //set game status to 2 (voting)
            db.query(`UPDATE Games SET status = 2 WHERE id = ${game_id}`, (err, updates) => {
                if(err){
                    console.error(err);
                    return;
                }
                //close voting after vote_time seconds
                setTimeout(() => {

                    //set game status to 1 (ingame)
                    db.query(`UPDATE Games SET status = 1 WHERE id = ${game_id}`, (err, updates) => {
                        if(err){
                            console.error(err);
                            return;
                        }
                        
                        //end vote, it has to be second because the game status has to be 1 (ingame) to prevent players from voting after the event is emitted
                        end_vote(game_id, true);
                    });
                
                }, vote_time * 1000)
            });
        });
    }
}

export default start_vote;