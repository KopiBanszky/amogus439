import * as mysql from 'mysql';
const db = mysql.createConnection({
   host: 'mysql.srkhost.eu',
   user: 'u20167_sSgOtKUVZg',
   password: 'WpPTwp21gkb7',
   database: 's20167_amogus'
});
db.connect((err) => {
   if(err) throw err;
   console.log('MySql Connected');
})

db.on('error', (err) => {
   console.log(err);
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

export default db;