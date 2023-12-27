"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../database/export_db_connection"));
exports.default = {
    path: '/api/manager/maps',
    method: 'GET',
    handler: function (req, res) {
        const sql = `SELECT DISTINCT map FROM Tasks`;
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
                message: 'Maps retrieved successfully',
                maps: result
            });
            return 200;
        });
    }
};
