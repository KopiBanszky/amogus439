"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
exports.default = {
    path: '/api/game/ingame/getTask',
    method: 'GET',
    handler: function (req, res) {
        const { task_id } = req.query;
        if ((task_id == undefined || task_id == null)) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const numID = task_id;
        const sql = `SELECT * FROM Tasks WHERE id = ${numID}`;
        export_db_connection_1.default.query(sql, (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            }
            ;
            if (result.length == 0) {
                res.status(404).send({
                    message: 'Player not found'
                });
                return 404;
            }
            const task = result[0];
            task.geo_pos = JSON.parse(task.geo_pos /* || JSON.stringify({latitude: 0, longitude: 0})*/);
            res.status(200).send({
                message: 'Task retrieved successfully',
                task: task
            });
            return 200;
        });
    }
};
