import db from '../../database/export_db_connection';
import {isEmpty, apiMethod} from '../../source/utility';



export default <apiMethod> {
    path: '/api/manager/get_tasks',
    method: 'GET',
    handler: function (req:any, res:any) {
        const sql = "SELECT * FROM Tasks";
        db.query(sql, (err, result) => {
            if(err) throw err;

            //parse geo_pos
            for(let i = 0; i < result.length; i++){
                result[i].geo_pos = JSON.parse(result[i].geo_pos);
            }
            // result[0].geo_pos = JSON.parse(result[0].geo_pos);
            res.status(200).send({
                message: result
            })
        });
    }
}