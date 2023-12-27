"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const utility_1 = require("../../../source/utility");
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
exports.default = {
    path: '/api/game/join/join_game',
    method: 'POST',
    handler: function (req, res) {
        const { username, game_id } = req.body;
        // Check if values are empty
        if ((0, utility_1.isEmpty)(username) || (game_id == undefined || game_id == null)) {
            res.status(400).send({
                message: 'Values cannot be empty',
                ok: false
            });
            return 400;
        }
        const sql = `SELECT * FROM Games WHERE id = ${game_id}`;
        export_db_connection_1.default.query(sql, (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                    ok: false
                });
                return 500;
            }
            ;
            if (result.length == 0) {
                res.status(404).send({
                    message: 'Game does not exist',
                    ok: false
                });
                return 404;
            }
            if (result[0].status != 0) {
                res.status(403).send({
                    message: 'Game already started',
                    ok: false
                });
                return 403;
            }
            res.status(200).send({
                message: 'Game is available to join',
                ok: true
            });
            return 200;
        });
    }
};
