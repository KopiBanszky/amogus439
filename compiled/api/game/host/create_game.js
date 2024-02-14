"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const export_db_connection_1 = __importDefault(require("../../../database/export_db_connection"));
const utility_1 = require("../../../source/utility");
function randNum(len) {
    let num = '';
    for (let i = 0; i < len; i++) {
        num += Math.floor(Math.random() * 10);
    }
    return num;
}
exports.default = {
    path: '/api/game/host/create_game',
    method: 'POST',
    handler: function (req, res) {
        const { username } = req.body;
        // Check if values are empty
        if ((0, utility_1.isEmpty)(username)) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }
        let game_id = randNum(6);
        const sql = `INSERT INTO Games (id) VALUES (${game_id})`;
        const game_upload = () => export_db_connection_1.default.query(sql, (err, result) => {
            if (err) {
                //if game_id already exists, generate a new one
                if (err.code == 'ER_DUP_ENTRY') {
                    game_id = randNum(6);
                    game_upload();
                }
                ;
                console.error(err);
                res.status(500).send({
                    message: 'Internal server error',
                });
                return 500;
            }
            ;
            res.status(200).send({
                message: 'Game created successfully',
                game_id: game_id
            });
            return 200;
        });
        game_upload();
    }
};
