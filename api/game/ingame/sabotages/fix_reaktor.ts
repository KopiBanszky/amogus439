import db from '../../../../database/export_db_connection';
import { Game } from '../../../../source/utility';


const reaktorfix = {
    event: 'reaktorfix',
    callback: async (args: any, socket: any) => {
        const game_id = args.game_id;
        const user_id = args.user_id;
        const game_sb_id = args.game_sb_id;

        //check if game exists
        const game_promise: any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 500, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'Game not found' });
                resolve(false);
            }
            resolve(result[0]);
        }));

        if (game_promise == false) return;

        const game: Game = game_promise;
        if (game.status != 1) {
            socket.emit('reaktorfix', { code: 403, message: 'Game not in progress' });
            return;
        }

        //check if player is in the game and alive
        const player_promise: any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 501, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'You are not in this game' });
                resolve(false);
            }
            resolve(result[0]);
        }));

        if (player_promise == false) return;
        const player: any = player_promise;
        if(player.dead){
            socket.emit('reaktorfix', { code: 403, message: 'You are dead' });
            return;
        }

        //check if sabotage exists
        const sabotage_promise: any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Game_sabotage WHERE id = ${game_sb_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 502, message: 'Internal server error' });
                resolve(false);
            }
            if (result.length == 0) {
                socket.emit('reaktorfix', { code: 403, message: 'Sabotage not found' });
                resolve(false);
            }
            resolve(result[0]);
        }));

        if (sabotage_promise == false) return;
        const sabotage: any = sabotage_promise;
        if(sabotage.tag == -1){
            socket.emit('reaktorfix', { code: 403, message: 'Sabotage fixed' });
            return;
        }

        //update sabotage
        db.query(`UPDATE Game_sabotage SET tag = 2 WHERE id = ${game_sb_id}`, (err, result) => {
            if (err) {
                console.error(err);
                socket.emit('reaktorfix', { code: 500, message: 'Internal server error' });
                return;
            }
            socket.emit('reaktorfix', { code: 200, message: 'Holding...' });
        });
    }
};

export default reaktorfix;