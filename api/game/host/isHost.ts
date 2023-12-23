import db from "../../../database/export_db_connection"

async function isHost(gameId: number, userId: number): Promise<boolean> {
    return new Promise((resolve, reject) => {
        db.query(`SELECT host FROM Players WHERE id = ${userId} AND game_id = ${gameId}`, (err, result) => {
            if(err){
                console.error(err);
                resolve(false);
            }
            else if(result.length == 0){
                resolve(false);
            }
            else resolve(result[0].host);
        });
    });
}

export default isHost;