import { Game, Player, apiMethod, isEmpty } from "../../../../source/utility";
import db from "../../../../database/export_db_connection";
import simple_sabotage from "./simple_sabotage";
import reaktor from "./reaktor";

export default <apiMethod>{
    path: '/api/game/ingame/sabotage',
    method: 'POST',
    handler: async function (req: any, res: any) {
        const {
            game_id,
            user_id,
            sabotage
        } = req.body;

        if (game_id == undefined || game_id == null || user_id == undefined || user_id == null || sabotage == undefined || sabotage == null) {
            res.status(400).send({
                message: 'Values cannot be empty'
            });
            return 400;
        }

        const player_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT * FROM Players WHERE game_id = ${game_id} AND id = ${user_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(500).send({
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                if (result.length == 0) {
                    res.status(404).send({
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
        if (player.team) {
            res.status(403).send({
                message: 'You are an impostor'
            });
            return 403;
        }

        const game_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT * FROM Games WHERE id = ${game_id}`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(501).send({
                        code: 501,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
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
        if (game_promise.status != 1) {
            res.status(403).send({
                code: 403,
                message: 'Game not in progress'
            });
            return 403;
        }

        const game:Game = game_promise;

        const sabotage_promise: any = await new Promise((resolve, reject) => {
            db.query(`SELECT *, Sabotages.id AS SID FROM Sabotages INNER JOIN Tasks ON (Sabotages.task_id = Tasks.id) WHERE name = '${sabotage}' AND map = '${game.map}'`, (err, result) => {
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
                        message: 'Sabotage not found'
                    });
                    resolve(false);
                    return 404;
                }
                console.log(result);
                resolve(result);
            });
        });

        if (sabotage_promise == false) return;

        const allowed = await new Promise((resolve, result) => {
            db.query(`SELECT * FROM Game_sabotage WHERE game_id = ${game_id} ORDER BY id DESC`, (err, result) => {
                if (err) {
                    console.error(err);
                    res.status(503).send({
                        code: 503,
                        message: 'Internal server error',
                    });
                    resolve(false);
                    return 500;
                }
                console.log(result);
                for (let index = 0; index < result.length; index++) {
                    const element = result[index];

                    if (element.tag > 0) {
                        res.status(403).send({
                            code: 403,
                            message: 'Sabotage already triggered'
                        });
                        resolve(false);
                        return 403;
                    }
                    if (element.tag == -1) {

                        const time = new Date(element.triggerd);
                        const current_time = new Date();

                        const COOLDOWN = 100 * 1000;

                        if (current_time.getTime() - time.getTime() < COOLDOWN) {
                            res.status(403).send({
                                code: 403,
                                message: 'Sabotage is on cooldown'
                            });
                            resolve(false);
                            return 403;
                        }
                    }

                }

                resolve(true);
                return 200;
            });
        });

        if (allowed == false) return;
        switch (sabotage) {
            case 'Reaktor':
                reaktor(sabotage_promise, game_id, game_id);
                break;
            case 'Lights':
                simple_sabotage(sabotage_promise[0], game_id ,game_id);
                break;
            case 'Navigation':
                simple_sabotage(sabotage_promise[0], game_id ,game_id);
                break;
            default:
                res.status(404).send({
                    code: 404,
                    message: 'Sabotage not found'
                });
                break;
        }
        res.status(200).send({
            code: 200,
            message: 'Sabotage triggered'
        });


    }
};