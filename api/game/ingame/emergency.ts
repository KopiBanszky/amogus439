import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { Player, Game, Task } from '../../../source/utility';

const report = {
    event: 'emergency',
    callback: async (socket: any, data: any) => {
        const {game_id, player_id} = data;
        const game_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('emergency', {code: 500, message: 'Error in database'});
                return;
            };
            if(result.length == 0) {
                resolve(null);
                socket.emit('emergency', {code: 404, message: 'Game not found'});
                return;
            }
            resolve(result[0]);
        }));
        if(game_prom == null) return;
        const game:Game =  game_prom;

        if(game.status != 1) {
            socket.emit('emergency', {code: 403, message: 'Game is not running'});
            return;
        }

        const player_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE player_id = ${player_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('emergency', {code: 500, message: 'Error in database'});
                return;
            };
            if(result.length == 0) {
                resolve(null);
                socket.emit('emergency', {code: 404, message: 'Player not found'});
                return;
            }
            resolve(result[0]);
        }));
        if(player_prom == null) return;
        const player:Player =  player_prom;
        if(player.dead){
            socket.emit('emergency', {code: 403, message: 'You are already dead'});
            return;
        }
        if(player.emergency >= game.emergencies){
            socket.emit('emergency', {code: 403, message: 'You have no more emergencies'});
            return;

        }

        db.query(`UPDATE Games SET status = 4 WHERE game_id = ${game_id}`, (err, result) => {
            if(err) {
                socket.emit('emergency', {code: 500, message: 'Error in database'});
                return;
            }
            socket.emit('emergency', {code: 200, message: 'emergency pressed'});
            io.to(`Game_${game_id}`).emit('emergency_called', {message: "Player called emergency", reporter: player});
        });

    }
}

export default report;