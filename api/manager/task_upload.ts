import db from '../../database/export_db_connection';
import {isEmpty, apiMethod} from '../../source/utility';



export default <apiMethod> {
    path: '/api/manager/task_upload',
    method: 'POST',
    handler: function (req:any, res:any) {
        const { task_name, geo_pos, map } = req.body;

        // Check if values are empty
        if(isEmpty(task_name) || (geo_pos == null) || isEmpty(map)) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const sql = `INSERT INTO Tasks (name, geo_pos, map) VALUES ('${task_name}', '${JSON.stringify(geo_pos)}', '${map}')`;
        db.query(sql, (err, result) => {
            if(err){
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            };
            res.status(200).send({
                message: 'Task uploaded successfully',
            });
            return 200;
        });
    }
}