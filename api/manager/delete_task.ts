import db from '../../database/export_db_connection';
import {isEmpty, apiMethod} from '../../source/utility';



export default <apiMethod> {
    path: '/api/manager/delete_task',
    method: 'DELETE',
    handler: function (req:any, res:any) {
        const { task_id } = req.body;

        // Check if values are empty
        if(task_id == null) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const sql = `DELETE FROM Tasks WHERE id = ${task_id}`;
        db.query(sql, (err, result) => {
            if(err){
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            };
            res.status(200).send({
                message: 'Task deleted successfully',
            });
            return 200;
        });
    }
};