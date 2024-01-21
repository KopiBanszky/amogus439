import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { Player, Game, Task } from '../../../source/utility';
import testIfGameEnd from './game_end';

const task_done = {
    event: 'task_done',
    callback: async (args:any, socket:any) => {
        const game_id:number = args.game_id;
        const user_id:number = args.user_id;
        const task_id:number = args.task_id;

        //check if game exists
        const game_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('task_done', {code: 500, message: 'Internal server error'});
                resolve({});
            }
            if(result.length == 0){
                socket.emit('task_done', {code: 403, message: 'Game not found'});
                resolve({});
            }
            resolve(result[0]);
        }));
        if(Object.keys(game_promise).length == 0) return;
        const game:Game = game_promise;
        if(game.status != 1){
            socket.emit('task_done', {code: 403, message: 'Game not in progress'});
            return;
        }

        //check if player is in the game and alive
        const player_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Players WHERE id = ${user_id} AND game_id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('task_done', {code: 500, message: 'Internal server error'});
                resolve(null);
            }
            if(result.length == 0){
                socket.emit('task_done', {code: 403, message: 'You are not in this game'});
                resolve(null);
            }
            resolve(result[0]);
        }));
        if(player_promise == null) return;
        const player:Player = player_promise;
        if(player.team){
            socket.emit('task_done', {code: 205, message: 'You are an impostor, the task does not count'});
            return;
        }

        //check if task exists
        const task_promise:any = await new Promise((resolve, reject) => db.query(`SELECT * FROM Tasks WHERE id = ${task_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('task_done', {code: 500, message: 'Internal server error'});
                resolve(null);
            }
            if(result.length == 0){
                socket.emit('task_done', {code: 403, message: 'Task not found'});
                resolve(null);
            }
            resolve(result[0]);
        }));
        if (task_promise == null) return;
        const task: Task = task_promise;


        player.tasks_done = JSON.parse(player.tasks_done.toString() || JSON.stringify([]));
        //check if task is already done
        if (player.tasks_done.includes(task_id)) {
            socket.emit('task_done', { code: 403, message: 'Task already done' });
            return;
        }

        //set task as done
        player.tasks_done.push(task_id);
        db.query(`UPDATE Players SET tasks_done = '${JSON.stringify(player.tasks_done)}' WHERE id = ${player.id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('task_done', {code: 500, message: 'Internal server error'});
                return;
            }
            socket.emit('task_done', {code: 200, message: 'Task done'});
            console.log(game.task_visibility, game_id );
            if(game.task_visibility) io.in(`Game_${game_id}`).emit('task_done_by_crew', {player_id: player.id, task_id: task_id});
            testIfGameEnd(game_id);
        });
    }
}

export default task_done;