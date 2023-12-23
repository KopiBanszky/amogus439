import { Server } from 'socket.io';
import { createServer } from 'http';
import { app } from '../../index';
import { instrument } from '@socket.io/admin-ui';
import * as EVNETS from './ws_exports';


const websocket_port:number = 8081;

const server = createServer(app);
const io = new Server(server, {
  cors: { 
    origin: ["https://admin.socket.io", "http://localhost:8080", "http://localhost:8081", 'null'],
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


const io_server = {server, websocket_port};

export {
  io,
  io_server,
};