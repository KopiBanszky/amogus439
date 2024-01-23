import {io} from '../websocket';
import db from '../../../database/export_db_connection';
import { join_room } from '../join/ws_join';
import { Game, isEmpty } from '../../../source/utility';

const create_new_game = {
    event: 'create_game',
    callback: (args:any, socket:any) => {
        const game_id = args.game_id;
        const username = args.username;

        if(isEmpty(username) || (game_id == undefined || game_id == null)) {
            socket.emit('create_game', {code: 400, message: 'Values cannot be empty'});
            return;
        }

        const sql = `SELECT * FROM Games WHERE id = ${game_id}`;
        db.query(sql, (err, game) => {
            if(err){
                console.error(err);
                socket.emit('create_game', {code: 500, message: 'Internal server error'});
                return;
            }
            if(game.length == 0){
                socket.emit('create_game', {code: 404, message: 'Game does not exist'});
                return;
            }
            const insertplayer_sql = `INSERT INTO Players (game_id, socket_id, name, color, host, tasks, tasks_done) VALUES (${game_id}, '${socket.id}', '${username}', 10027008, 1, '[]', '[]')`;
            db.query(insertplayer_sql, (err, player_res) => {
                if(err){
                    console.error(err);
                    socket.emit('create_game', {code: 500, message: 'Internal server error'});
                    return;
                }
                const gameType:Game = game[0];
                console.log(gameType);

                socket.emit('create_game', {
                    code: 200,
                    message: 'Game created successfully',
                    data: {
                        game: gameType,
                        player: {
                            id: player_res.insertId,
                            game_id: game_id,
                            socket_id: socket.id,
                            name: username,
                            color: 10027008,
                            emergency: 0,
                            tasks: [],
                            task_done: [],
                            team: true,
                            geo_pos: {latitude: 0, longitude: 0},
                            dead: false,
                            host: true,
                            votes: 0,
                            voted: false,
                        }
                    }
                });
                join_room(`Game_${game_id}`, socket);
            })
        });
    }
}

export {
    create_new_game
}