import { io } from '../websocket';
import db from '../../../database/export_db_connection';
import { Game, Player, Task, isEmpty } from '../../../source/utility';
import isHost from './isHost';

const start = {
    event: 'start_game',
    callback: async (args:any, socket:any) => {
        const gameID:number = args.game_id;
        const user_id:number = args.user_id;

        if(!await isHost(gameID, user_id)){
            socket.emit('start_game', {code: 403, message: 'You are not the host'});
            return;
        }

        //check if game exists
        db.query(`SELECT * FROM Games WHERE id = ${gameID}`, (err, game_res) => {
            if(err){
                console.error(err);
                return;
            }

            //check if map is selected
            const game:Game = game_res[0];
            if(isEmpty(game.map)){
                socket.emit('start_game', {code: 500, message: 'Map not selected'});
                return;
            }

            //get players
            db.query(`SELECT * FROM Players WHERE game_id = ${gameID}`, (err, players_res) => {
                if(err){
                    console.error(err);
                    return;
                }
                const players:Player[] = players_res;

                //check if there are enough players
                if(players.length < 3){
                    socket.emit('start_game', {code: 500, message: 'Not enough players'});
                    return;
                }

                //set the max impostor count
                let impostors:number = Math.floor(players.length / 3);
                if(impostors > game.impostor_max) impostors = game.impostor_max;
                const impostors_ids:number[] = [];
                for(let i = 0; i < impostors; i++){
                    let rand = Math.floor(Math.random() * players.length);
                    while(impostors_ids.includes(players[rand].id)){
                        rand = Math.floor(Math.random() * players.length);
                    }
                    impostors_ids.push(players[rand].id);
                }

                //get tasks
                db.query(`SELECT * FROM Tasks WHERE map = '${game.map}'`, (err, tasks_res) => {
                    const Tasks:Task[] = tasks_res;

                    //set tasks to players
                    players.map((player:Player) => {
                        player.tasks = [];
                        player.task_done = [];

                        //add tasks to player. max task count is setted in game settings or tasks.length
                        for(let i = 0; i < (Tasks.length < game.task_number ? Tasks.length : game.task_number); i++){
                            let rand = Math.floor(Math.random() * Tasks.length);
                            while(player.tasks.includes(Tasks[rand].id)){
                                rand = Math.floor(Math.random() * Tasks.length);
                            }
                            player.tasks.push(Tasks[rand].id);
                        }

                        //update players
                        db.query(`UPDATE Players SET tasks = '${JSON.stringify(player.tasks)}', task_done = '${JSON.stringify(player.task_done)}', team = ${impostors_ids.includes(player.id)} WHERE id = ${player.id}`, (err, result) => {
                            if(err){
                                console.error(err);
                                return;
                            }
                            io.in(player.socket_id).emit('role_update', {player, impostors: (player.team ? impostors_ids : null)});
                        });
                    });

                    //update game status to 1 (running)
                    const sql = `UPDATE Games SET status = 1 WHERE id = ${gameID}`;
                    db.query(sql, (err, result) => {
                        if(err){
                            console.error(err);
                            return;
                        }
                        io.in(`Game_${gameID}`).emit('game_started', {code: 200, message: 'Game started successfully'});
                    });
                });
            });
        });
    }
}