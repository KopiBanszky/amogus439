import db from "../../../database/export_db_connection";
import { io } from "../websocket";
import { Player, Game, Task } from "../../../source/utility";

function testIfGameEnd(game_id:number) {
    const sql = `SELECT * FROM Players WHERE game_id = ${game_id}`;
    db.query(sql, (err, result) => {
        if(err){
            console.error(err);
            return;
        }
        const players:Player[] = result;
        let impostors:number = 0;
        let crewmates:number = 0;
        const impostors_list: Player[] = []; // Initialize impostors_list as an empty array with type Player[]
        let task_done:number = 0;
        let task_total:number = 0;
        players.map((player:Player) => {
            if(player.team) impostors_list.push(player); // Push player to impostors_list if player.team is true
            if(player.dead) return;
            if(player.team){
                impostors++;
            }else{
                crewmates++;
                task_done += player.tasks_done.length;
                task_total += player.tasks.length;
            }
        });

        const isGameEnd:boolean = (impostors == 0 || crewmates <= impostors || task_done == task_total);
        if(isGameEnd) {

            if(impostors == 0 || task_done == task_total){
                io.in(`Game_${game_id}`).emit('game_end', {code: 200, message: 'Crewmates won', impostors: impostors_list});
                return;
            }
            if(crewmates <= impostors){
                io.in(`Game_${game_id}`).emit('game_end', {code: 201, message: 'Impostors won', impostors: impostors_list});
                return;
            }
        }
    });
}

export default testIfGameEnd;