"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../database/export_db_connection"));
exports.default = {
    path: '/api/manager/delete_task',
    method: 'DELETE',
    handler: function (req, res) {
        const { task_id } = req.body;
        // Check if values are empty
        if (task_id == null) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const sql = `DELETE FROM Tasks WHERE id = ${task_id}`;
        export_db_connection_1.default.query(sql, (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            }
            ;
            res.status(200).send({
                message: 'Task deleted successfully',
            });
            return 200;
        });
    }
};
