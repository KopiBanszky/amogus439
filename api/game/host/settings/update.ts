import { apiMethod } from "../../../../source/utility";
import db from "../../../../database/export_db_connection";
import isHost from "../isHost";

export default <apiMethod> {
    path: '/api/game/host/settings/update',
    method: 'PUT',
    handler: async function (req:any, res:any) {
        const options:string[] = ["task_num", "task_visibility", "vote_time", "anonymus_vote", "kill_cooldown", "impostor_max", "emergencies", "map"];
        const { game_id, user_id } = req.body;
        
        if(!await isHost(game_id, user_id)){
            res.status(403).send({
                message: 'You are not the host of this game'
            });
            return 403;
        }

        let sqlVariables:string = "";
        
        let x = 0;
        const bodyKeys = Object.keys(req.body);
        for(let i of bodyKeys){
            if(!options.includes(i)) continue;
            if(i == "map") req.body[i] = `'${req.body[i]}'`;
            sqlVariables += `${i} = ${req.body[i]}${x == bodyKeys.length-2 ? "":","} `;
            ++x;
        }
        const sql:string = `UPDATE Games SET ${sqlVariables} WHERE id = ${game_id}`;
        db.query(sql, (err, result) => {
            if(err){
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            };
            res.status(200).send({
                message: 'Game settings updated successfully'
            });
            return 200;
        })

    }
};