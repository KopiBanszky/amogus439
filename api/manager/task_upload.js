"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../database/export_db_connection"));
const utility_1 = require("../../source/utility");
exports.default = {
    path: '/api/manager/task_upload',
    method: 'POST',
    handler: function (req, res) {
        const { task_name, geo_pos, map } = req.body;
        // Check if values are empty
        if ((0, utility_1.isEmpty)(task_name) || (geo_pos == null) || (0, utility_1.isEmpty)(map)) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const sql = `INSERT INTO Tasks (name, geo_pos, map) VALUES ('${task_name}', '${JSON.stringify(geo_pos)}', '${map}')`;
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
                message: 'Task uploaded successfully',
            });
            return 200;
        });
    }
};
