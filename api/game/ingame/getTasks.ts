import db from "../../../database/export_db_connection";
import { Player, apiMethod, isEmpty } from "../../../source/utility";

export default <apiMethod> {
    path: '/api/game/ingame/getTask',
    method: 'GET',
    handler: function (req:any, res:any) {
        const { task_id } = req.query;

        if((task_id == undefined || task_id == null)){
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const numID:number = task_id;
        const sql = `SELECT * FROM Tasks WHERE id = ${numID}`;
        db.query(sql, (err, result) => {
            if(err){
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            };
            if(result.length == 0){
                res.status(404).send({
                    message: 'Player not found'
                });
                return 404;
            }
            const task = result[0];
            task.geo_pos = JSON.parse(task.geo_pos/* || JSON.stringify({latitude: 0, longitude: 0})*/);


            res.status(200).send({
                message: 'Task retrieved successfully',
                task: task
            });
            return 200;
        })
    }
};