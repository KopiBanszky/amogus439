"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../database/export_db_connection"));
exports.default = {
    path: '/api/game/ingame/getGame',
    method: 'GET',
    handler: function (req, res) {
        const { game_id } = req.query;
        if (game_id == undefined || game_id == null) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }
        const sql = `SELECT * FROM Games WHERE id = ${game_id}`;
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
                    message: 'Game not found'
                });
                return 404;
            }
            res.status(200).send({
                message: 'Game retrieved successfully',
                player: result[0]
            });
            return 200;
        });
    }
};
