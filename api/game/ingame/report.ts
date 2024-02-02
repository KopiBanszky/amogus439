import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { Player, Game, Task } from '../../../source/utility';

const report = {
    event: 'report',
    callback: async (data: any, socket: any) => {
        const {game_id, player_id, dead_id} = data;
        const game_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', {code: 500, message: 'Error in database'});
                return;
            };
            if(result.length == 0) {
                resolve(null);
                socket.emit('report', {code: 404, message: 'Game not found'});
                return;
            }
            resolve(result[0]);
        }));
        if(game_prom == null) return;
        const game:Game =  game_prom;

        if(game.status != 1) {
            socket.emit('report', {code: 403, message: 'Game is not running'});
            return;
        }

        const player_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${player_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', {code: 500, message: 'Error in database'});
                return;
            };
            if(result.length == 0) {
                resolve(null);
                socket.emit('report', {code: 404, message: 'Player not found'});
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
            socket.emit('report', {code: 403, message: 'You are already dead'});
            return;
        }

        
        const deadPlayer_prom:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${dead_id}`, (err, result) => {
            if (err) {
                resolve(null);
                socket.emit('report', {code: 500, message: 'Error in database'});
                return;
            };
            if(result.length == 0) {
                resolve(null);
                socket.emit('report', {code: 404, message: 'Player not found'});
                return;
            }
            resolve(result[0]);
        }));
        if(deadPlayer_prom == null) return;
        deadPlayer_prom.tasks = JSON.parse(deadPlayer_prom.tasks);
        deadPlayer_prom.tasks_done = JSON.parse(deadPlayer_prom.tasks_done || "[]");
        deadPlayer_prom.geo_pos = JSON.parse(deadPlayer_prom.geo_pos || JSON.stringify({latitude: 0, longitude: 0}));
        const deadPlayer:Player =  deadPlayer_prom;

        if(!deadPlayer.dead){
            socket.emit('report', {code: 403, message: 'Player is not dead'});
            return;
        }

        db.query(`UPDATE Games SET status = 4 WHERE id = ${game_id}`, (err, result) => {
            if(err) {
                socket.emit('report', {code: 500, message: 'Error in database'});
                return;
            }
            socket.emit('report', {code: 200, message: 'Reported'});
            io.in(`Game_${game_id}`).emit('reported_player', {message: "Player reported", reporter: player, reported: deadPlayer});
        });

    }
}

export default report;