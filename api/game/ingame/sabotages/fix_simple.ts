import { Game, Player, apiMethod, isEmpty } from "../../../../source/utility";
import db from "../../../../database/export_db_connection";
import { io } from "../../websocket";

export default <apiMethod>{
    path: '/api/game/ingame/sabotage/fix',
    method: 'POST',
    handler: async function (req: any, res: any) {
        const {
            game_id,
            user_id,
            sabotage_id,
            name
        } = req.body;

        if (game_id == undefined || game_id == null || user_id == undefined || user_id == null) {
            res.status(400).send({
                code: 400,
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const player_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND id = ${user_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(502).send({
                        code: 502,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    res.status(404).send({
                        code: 404,
                        message: 'Player not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });

        if (player_promise == false) return;

        const player: Player = player_promise;

        const game_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(501).send({
                        code: 501,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 501;
                }
                if (result.length == 0) {
                    res.status(404).send({
                        code: 404,
                        message: 'Game not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });

        if (game_promise == false) return;

        const game: Game = game_promise;

        if (game.status != 1) {
            res.status(403).send({

                code: 403,
                message: 'Game not in progress'
            });
            return 403;
        }

        const sabotage_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT * FROM Game_sabotage WHERE id = ${sabotage_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(500).send({
                        code: 500,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    res.status(404).send({
                        code: 404,
                        message: 'Sabotage not found'
                    });
                    resolve(false);
                    return 404;
                }
                resolve(result[0]);
            });
        });

        if (sabotage_promise == false) return;

        const sabotage: any = sabotage_promise;

        if(sabotage.tag == -1){
            res.status(403).send({
                code: 403,
                message: 'Sabotage already fixed'
            });
            return 403;
        }

        db.query(`UPDATE Game_sabotage SET tag = -1 WHERE id = ${sabotage_id}`, (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send({
                    code: 500,
                    message: 'Internal server error',
                });
                return 500;
            }

            res.status(200).send({
                code: 200,
                message: 'Sabotage fixed successfully'
            });
    
            io.to(`Game_${game_id}`).emit('sabotage_fixed', {
                sabotage_id: sabotage_id,
                type: name
            });
        });

    }
}