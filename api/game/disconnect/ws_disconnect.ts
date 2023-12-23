import {io} from '../websocket';
import db from '../../../database/export_db_connection';

const disconnect = {
    event: 'disconnect',
    callback: (args:any, socket:any) => {
        const get_plyr_sql = `SELECT * FROM Players WHERE socket_id = '${socket.id}'`;
        db.query(get_plyr_sql, (err, plyr) => {
            if(err){
                console.error(err);
                return;
            }
            if(plyr.length == 0) return;
            const sql = `DELETE FROM Players WHERE socket_id = '${socket.id}'`;
            db.query(sql, (err, result) => {
                if(err){
                    console.error(err);
                    return;
                }
                io.in(`Game_${plyr[0].game_id}`).emit('player_disconnected', {id: plyr[0].id, socket_id: socket.id, username: plyr[0].name});
            });
        });
    }
};

export default disconnect;