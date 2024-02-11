import db from '../../../../database/export_db_connection';
import { io } from '../../websocket';

export function simple_sabotage(sabotage: any, game_id:number, user_id: number){
    db.query(`INSERT INTO Game_sabotage SET triggerd = CURRENT_TIMESTAMP(), ?`, {
        game_id: game_id,
        sabotage_id: sabotage.SID,
        tag: 1
    }, (err, result) => {
        if(err){
            console.error(err);
            return;
        }
        sabotage.game_sb_id = result.insertId;
        io.in(`Game_${game_id}`).emit('sabotage_trigg', {
            type: sabotage.name,
            sabotage: sabotage
        });
    });
}