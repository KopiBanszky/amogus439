import db from "../../../../database/export_db_connection";
import { io } from "../../websocket";
import testIfGameEnd from "../game_end";


async function check_cooldown(ids: number[], game_id:number, time:number){
    const results:any = await new Promise((resolve, reject) => {
        db.query(`SELECT * FROM Game_sabotage WHERE id = ${ids[0]} OR id = ${ids[1]}`, (err, result) => {
            if(err){
                console.error(err);
                resolve(false);
                return;
            }
            resolve(result);
            db.query(`UPDATE Game_sabotage SET tag = 1 WHERE id = ${ids[0]} OR id = ${ids[1]}`, (err, result) => {
                if(err){
                    console.error(err);
                    return;
                }
            });
        });
    });

    if(results.length != 2){
        return 400; //sabotage not found
    }

    const now = new Date().getTime();

    const trigger1 = new Date(results[0].triggerd).getTime();
    const trigger2 = new Date(results[1].triggerd).getTime();

    // console.log(trigger1, trigger2, now, time * 1000);
    // console.log(trigger1 - now, now - trigger2, time * 1000);

    if(
        //fix: added new Date() to results
        ((now - trigger1) > ((time + 4) * 1000)) ||
        ((now - trigger2) > ((time + 4) * 1000))){
        return 203; //dead
    }

    if(results[0].tag == 2 && results[1].tag == 2){
        return 202; //fixed
    }

    return 201; //cooldown
}


export default function (sabotages: any[], game_id:number, insertedIDS:number[]){
    let time:number = sabotages[0].time;

    const interval = setInterval( async () => {
        const result = await check_cooldown(insertedIDS, game_id, sabotages[0].time);

        if(result == 201){
            return;
        }


        db.query(`UPDATE Game_sabotage SET tag = -1, triggerd = CURRENT_TIMESTAMP() WHERE id = ${insertedIDS[0]} OR id = ${insertedIDS[1]}`, (err, result) => {
            if(err){
                console.error(err);
                return;
            }
        });

        // time -= 1;
        // if(time > 0) return;

        if(result == 202){
            io.to(`Game_${game_id}`).emit('sabotage_fixed', {
                type: "Reaktor",
                sabotages: sabotages
            });
        }

        if(result == 203){
            testIfGameEnd(game_id, true);
        }
        if(result == 202 || result == 203 || result == 400){
            clearInterval(interval);
        }

    }, 1000);

}