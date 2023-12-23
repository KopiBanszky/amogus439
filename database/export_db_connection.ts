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

export default db;