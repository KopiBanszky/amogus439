import * as mysql from 'mysql';
import dotenv from 'dotenv';

dotenv.config();
const db = mysql.createConnection({
   host: process.env.DB_HOST || 'localhost',
   user: process.env.DB_USER || 'root',
   password: process.env.DB_PASS || 'root',
   database: process.env.DB_NAME || 'amogus'
});
db.connect((err) => {
   if(err) throw err;
   console.log('MySql Connected');
})

db.on('error', (err) => {
   console.log(err);
   if(!err.fatal) db.destroy();
   if(err.code === 'PROTOCOL_CONNECTION_LOST') {
       db.connect((err) => {
           if(err) throw err;
           console.log('MySql Connected');
       })
   } else {
        console.log(err);
        db.connect((err) => {
            if(err) throw err;
            console.log('MySql Connected');
        })
   }
});

const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
function randCode():string{
    let code = "";
    for(let i = 0; i < 8; i++){
        if(Math.random() > 0.5) code += Math.floor(Math.random() * 10).toString();
        code += letters[Math.floor(Math.random() * letters.length)];
    }
    return code;
}

const toUpload:any = [
    {name: "Képválogatás", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445300, lon: 18.912925}), map: "Törökb"},
    {name: "Matekos", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.444983, lon: 18.912854}), map: "Törökb"},
    {name: "Emergency", code: randCode(), type: 2, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445215, lon: 18.913069}), map: "Törökb"},
    {name: "Pont összekötés", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445538, lon: 18.912961}), map: "Törökb"},
    {name: "Reaktor", code: randCode(), type: 3, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445660, lon: 18.912834}), map: "Törökb"},
    {name: "Refuel", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445511, lon: 18.912402}), map: "Törökb"},
    {name: "Mikroszkóp", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445295, lon: 18.912466}), map: "Törökb"},
    {name: "Szénakazal", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445171, lon: 18.912409}), map: "Törökb"},
    {name: "Kirakó Katalin", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.444357, lon: 18.912983}), map: "Törökb"},
    {name: "Árkereső", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.444596, lon: 18.913143}), map: "Törökb"},
    {name: "Lights", code: randCode(), type: 3, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445228, lon: 18.912586}), map: "Törökb"},
    {name: "Kábelcsatlakozás", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.445228, lon: 18.912586}), map: "Törökb"},
    {name: "Számlakat", code: randCode(), type: 0, connect_id: 0, geo_pos: JSON.stringify({lat: 47.444964, lon: 18.913186}), map: "Törökb"},
];

// for (let index = 0; index < toUpload.length; index++) {
//     const element = toUpload[index];
//     db.query(`INSERT INTO Tasks (name, code, type, connect_id, geo_pos, map) VALUES ('${element.name}', '${element.code}', ${element.type}, ${element.connect_id}, '${element.geo_pos}', '${element.map}')`, (err, result) => {
//         if(err) {
//             console.log(index, element)
//             throw err
//         };
//         console.log(result);
//     });
    
// }

export default db;