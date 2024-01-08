import { Server } from 'socket.io';

import http from 'http';
import { app } from '../../index';
import { instrument } from '@socket.io/admin-ui';
import * as EVNETS from './ws_exports';

//-----PRODUCTION-----
/*const https = require("https");
const fs = require("fs");
const key = fs.readFileSync("./private.key");
const cert = fs.readFileSync("./certificate.crt");

const cred = {
        key,
        cert
};

const server = https.createServer(cred, index_1.app);*/
//-----PRODUCTION-----

//----DEVELOPMENT-----

const server = http.createServer(app);

//----DEVELOPMENT-----

const io = new Server(server, {
  cors: { 
    origin: ["https://admin.socket.io", "http://13.53.185.194:8080", "http://13.53.185.194:8081", 'null'],
    credentials: true,
  },
});

instrument(io, {
  auth: {
    type: "basic",
    username: "lopany",
    password: "$2b$10$heqvAkYMez.Va6Et2uXInOnkCT6/uQj1brkrbyG3LpopDklcq7ZOS" // "changeit" encrypted with bcrypt
  },
  mode: "development"
})

io.on('connection', (socket) => {
  console.log('a user connected, id: ' + socket.id);

  
  for (let route of Object.values(EVNETS.default)){
    if(route.event){
      socket.on(route.event, (args:any) => route.callback(args, socket));
    }
  }

  return socket;
});

export {
  io,
  server
};
// const io_server = {server, websocket_port};

// export {
//   io,
//   io_server,
// };