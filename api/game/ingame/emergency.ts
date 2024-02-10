import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { Player, Game, Task } from '../../../source/utility';

const report = {
    event: 'emergency',
    callback: async (data: any, socket: any) => {
        const {game_id, player_id} = data;
        const game_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                resolve(null);
                console.error(err);
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

        const player_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${player_id}`, (err, result) => {
            if (err) {
                resolve(null);
                console.error(err);
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
        player_prom.tasks = JSON.parse(player_prom.tasks);
        player_prom.tasks_done = JSON.parse(player_prom.tasks_done || "[]");
        player_prom.geo_pos = JSON.parse(player_prom.geo_pos || JSON.stringify({latitude: 0, longitude: 0}));
        const player:Player =  player_prom;
        if(player.dead){
            socket.emit('emergency', {code: 403, message: 'You are already dead'});
            return;
        }
        if(player.emergency >= game.emergencies){
            socket.emit('emergency', {code: 403, message: 'You have no more emergencies'});
            return;

        }
        player.emergency++;

        db.query(`UPDATE Games SET status = 4 WHERE id = ${game_id}`, (err, result) => {
            if(err) {
                console.error(err);
                socket.emit('emergency', {code: 500, message: 'Error in database'});
                return;
            }
            socket.emit('emergency', {code: 200, message: 'emergency pressed'});
            io.in(`Game_${game_id}`).emit('emergency_called', {message: "Player called emergency", reporter: player});
        });
        db.query(`UPDATE Players SET emergency = ${player.emergency} WHERE id = ${player_id}`, (err, result) => {
            if(err) {
                console.error(err);
                return;
            }
        });
    }
}

export default report;