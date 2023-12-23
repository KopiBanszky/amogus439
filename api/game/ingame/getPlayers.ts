import db from "../../../database/export_db_connection";
import { apiMethod, isEmpty } from "../../../source/utility";

export default <apiMethod> {
    path: '/api/game/ingame/getPlayers',
    method: 'GET',
    handler: function (req:any, res:any) {
        const { game_id } = req.query;

        if(game_id == undefined || game_id == null){
            res.status(400).send({
                message: 'Value cannot be empty'
            });
            return 400;
        }

        const sql = `SELECT * FROM Players WHERE game_id = ${game_id}`;
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
                    message: 'No players found'
                });
                return 404;
            }
            res.status(200).send({
                message: 'Players retrieved successfully',
                players: result
            });
            return 200;
        })
    }
};