import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { Player, Game, Task } from '../../../source/utility';
import testIfGameEnd from './game_end';

const kill = {
    event: 'kill',
    callback: async (args:any, socket:any) => {
        const game_id:number = args.game_id;
        const user_id:number = args.user_id;
        const target_id:number = args.target_id;

        //check if game exists
        const game_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('kill', {code: 500, message: 'Internal server error'});
                resolve({});
            }
            if(result.length == 0){
                socket.emit('kill', {code: 403, message: 'Game not found'});
                resolve({});
            }
            resolve(result[0]);
        }));
        if(Object.keys(game_promise).length == 0) return;
        const game:Game = game_promise;
        if(game.status != 1){
            socket.emit('kill', {code: 403, message: 'Game not in progress'});
            return;
        }

        //check if player is in the game and alive
        const player_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id} AND dead = 0`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('kill', {code: 500, message: 'Internal server error'});
                resolve(null);
            }
            if(result.length == 0){
                socket.emit('kill', {code: 403, message: 'You are not in this game or you are dead'});
                resolve(null);
            }
            resolve(result[0]);
        }));
        if(player_promise == null) return;
        player_promise.tasks = JSON.parse(player_promise.tasks);
        player_promise.tasks_done = JSON.parse(player_promise.tasks_done || "[]");
        player_promise.geo_pos = JSON.parse(player_promise.geo_pos || JSON.stringify({latitude: 0, longitude: 0}));
        const player:Player = player_promise;

        //check if target is in the game and alive
        const target_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${target_id} AND game_id = ${game_id} AND dead = 0`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('kill', {code: 500, message: 'Internal server error'});
                resolve(null);
            }
            if(result.length == 0){
                socket.emit('kill', {code: 403, message: 'Target not found'});
                resolve(null);
            }
            resolve(result[0]);
        }));
        if(target_promise == null) return;
        target_promise.tasks = JSON.parse(target_promise.tasks);
        target_promise.tasks_done = JSON.parse(target_promise.tasks_done || "[]");
        target_promise.geo_pos = JSON.parse(target_promise.geo_pos || JSON.stringify({latitude: 0, longitude: 0}));
        const target:Player = target_promise;


        //check if player is impostor
        if(!player.team){
            socket.emit('kill', {code: 403, message: 'You are not an impostor'});
            return;
        }

        //check if target is impostor
        if(target.team){
            socket.emit('kill', {code: 403, message: 'Target is an impostor'});
            return;
        }

        db.query(`UPDATE Players SET dead = 1 WHERE id = ${target_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('kill', {code: 500, message: 'Internal server error'});
                return;
            }
            socket.emit('kill', {code: 200, message: 'Killed successfully'});
            console.log(target.socket_id, target.name);
            

            io.to(target.socket_id).emit('got_killed', {player});
            testIfGameEnd(game_id);
        });
    }
}

export default kill;