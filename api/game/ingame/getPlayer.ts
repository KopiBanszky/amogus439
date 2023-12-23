import db from "../../../database/export_db_connection";
import { apiMethod, isEmpty } from "../../../source/utility";

export default <apiMethod> {
    path: '/api/game/ingame/getPlayer',
    method: 'GET',
    handler: function (req:any, res:any) {
        const { socket_id, user_id } = req.query;

        if(isEmpty(socket_id) && (user_id == undefined || user_id == null)){
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const sql = `SELECT * FROM Players WHERE socket_id = ${socket_id} AND user_id = ${user_id}`;
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
            res.status(200).send({
                message: 'Player retrieved successfully',
                player: result[0]
            });
            return 200;
        })
    }
};