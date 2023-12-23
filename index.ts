import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import * as API from './api/exports';
import { apiMethod } from './source/utility';
import { Server } from 'socket.io';
import http from 'http';
import { io, io_server } from './api/game/websocket';

const app = express();
app.use(express.json());
app.use(cors());
app.set('view engine', 'ejs');
const urlencodedParser = bodyParser.urlencoded({ extended: false});
const port:number = 8080;
app.listen(port, () => console.info(`Az app fut ezen a porton: ${ port }\nhttp://localhost:${ port }/`));
app.use(express.static(__dirname + '/public'));

io_server.server.listen(io_server.websocket_port, () => console.info(`A websocket szerver ezen a porton fut: ${ io_server.websocket_port }\nhttp://localhost:${ io_server.websocket_port }/`));

// open express connection
// app.get(API.default.get_tasks.path, (req:any, res:any) => API.default.get_tasks.handler(req, res));

for (let route of Object.values(API.default)){
    // const route:apiMethod = API.default[i];
    // console.log(route.path, route.method);
    if(route.method && route.method == 'POST'){
        app.post(route.path, urlencodedParser, route.handler);
    }
    if(route.method && route.method == 'GET'){
        app.get(route.path, route.handler);
    }
    if(route.method && route.method == 'DELETE'){
        app.delete(route.path, route.handler);
    }
    if(route.method && route.method == 'PUT'){
        app.put(route.path, route.handler);
    }
}

export {
    port,
    app
};