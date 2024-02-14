"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../database/export_db_connection"));
exports.default = {
    path: '/api/manager/get_tasks',
    method: 'GET',
    handler: function (req, res) {
        const { mapName } = req.query;
        const sql = `SELECT * FROM Tasks ${mapName ? `WHERE map = '${mapName}'` : ''}`;
        export_db_connection_1.default.query(sql, (err, result) => {
            if (err)
                throw err;
            //parse geo_pos
            for (let i = 0; i < result.length; i++) {
                result[i].geo_pos = JSON.parse(result[i].geo_pos);
            }
            // result[0].geo_pos = JSON.parse(result[0].geo_pos);
            res.status(200).send({
                message: result
            });
        });
    }
};
