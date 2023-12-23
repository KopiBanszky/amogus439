import { apiMethod } from "../../source/utility";
import db from "../../database/export_db_connection";

export default <apiMethod> {
    path: '/api/manager/maps',
    method: 'GET',
    handler: function (req:any, res:any) {
        const sql = `SELECT DISTINCT map FROM Tasks`;
        db.query(sql, (err, result) => {
            if(err){
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            };
            res.status(200).send({
                message: 'Maps retrieved successfully',
                maps: result
            });
            return 200;
        })
    }
};