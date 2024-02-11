import db from '../../../../database/export_db_connection';
import { io } from '../../websocket';
import count_down from './count_down';

export async function reaktor(sabotages: any[], game_id: number, user_id: number) {
    const connected = sabotages.find(sabotage => sabotage.type == 42);
    const ids:number[] = [];
    for (let index = 0; index < sabotages.length; index++) {
        const sabotage = sabotages[index];
        const result:any = await new Promise((resolve, reject) => {
            db.query(`INSERT INTO Game_sabotage SET triggerd = CURRENT_TIMESTAMP(), ?`, {
                game_id: game_id,
                sabotage_id: sabotage.SID == connected.SID ? connected.connect_id : sabotage.SID,
                tag: 1
            }, (err, result) => {
                if (err) {
                    console.error(err);
                    resolve(false);
                    return;
                }
                resolve(result);
            });
        });
        if (result == false) continue;
        ids.push(result.insertId);
        sabotages[index].game_sb_id = result.insertId;
    }

    io.to(`Game_${game_id}`).emit('sabotage_trigg', {
        type: "Reaktor",
        sabotage: sabotages
    });
    count_down(sabotages, game_id, ids);
}