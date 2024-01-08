import { io } from '../websocket';
import { Player, COLORS, randomNum } from '../../../source/utility';
import db from '../../../database/export_db_connection';
import { Socket } from 'socket.io';
import { DefaultEventsMap } from 'socket.io/dist/typed-events';

function update_players(game_id:number, player:Player, socket_id:string, player_id:number){
    io.in(`Game_${game_id}`).emit('update_players', {username: player.name, color: player.color, socket_id: socket_id, id: player_id});
}

function join_room(room:string, socket: Socket<DefaultEventsMap, DefaultEventsMap, DefaultEventsMap, any>){
    socket.join(room);
    console.log(`a user connected to ${room}`);
}


const create_new_player = {
    event: 'join_game',
    callback: async (args:any, socket: Socket<DefaultEventsMap, DefaultEventsMap, DefaultEventsMap, any>) => {
        const game_id:number = args.game_id;
        const name:string = args.name;

        const gameStarted = new Promise((resolve, reject) => db.query(`SELECT status FROM Games WHERE id = ${game_id}`, (err, result) => {
            if(err){
                console.error(err);
                socket.emit('join_game', {code: 500, message: 'Internal server error'});
                resolve(true);
            }
            if(result.length == 0){
                socket.emit('join_game', {code: 400, message: 'Game not found'});
                resolve(true);
            }
            if(result[0].status != 0){
                socket.emit('join_game', {code: 403, message: 'Game already started'});
                resolve(true);
            }
            resolve(false);
        }));

        if(await gameStarted) return;

        db.query(`SELECT * FROM Players WHERE game_id = ${game_id}`, (err, players_res) => {
            if(err){
                console.error(err);
                return;
            }
    
            let color:number = COLORS[randomNum(0, COLORS.length - 1)];
            // players_res.map((player:Player) => {
            //     if(player.color == color){
            //         color = COLORS[randomNum(0, COLORS.length - 1)];
            //     }
            // });

            while(players_res.find((player:Player) => player.color == color) || color == 0){
                color = COLORS[randomNum(0, COLORS.length - 1)];
            }
    
            db.query(`INSERT INTO Players (game_id, socket_id, name, color) VALUES (${game_id}, '${socket.id}', '${name}', ${color})`, (err, result) => {
                if(err){
                    console.error(err);
                    socket.emit('join_game', {code: 500, message: 'Internal server error'});
                    return;
                }
                socket.emit('join_game', {code: 200, message: 'Joined successfully', 
                    players: players_res,
                })

                const player:Player = {
                    id: result.insertId,
                    game_id: game_id,
                    socket_id: socket.id,
                    name: name,
                    color: color,
                    emergency: 0,
                    tasks: [],
                    task_done: [],
                    team: false,
                    geo_pos: {latitude: 0, longitude: 0},
                    dead: false,
                    host: false,
                    votes: 0,
                    voted: false,
                };
                join_room(`Game_${game_id}`, socket);
                update_players(game_id, player, socket.id, result.insertId);
            });
        });
    }

}

export {
    create_new_player,
    join_room
}