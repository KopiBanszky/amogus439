import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import * as API from './api/exports';

const app = express();
app.use(express.json());
app.use(cors());
app.set('view engine', 'ejs');
const urlencodedParser = bodyParser.urlencoded({ extended: false});
const port:number = 8080;
app.listen(port, () => console.info(`Az app fut ezen a porton: ${ port }\nhttp://13.53.185.194:${ port }/`));
app.use(express.static(__dirname + '/public'));

// io_server.server.listen(io_server.websocket_port, () => console.info(`A websocket szerver ezen a porton fut: ${ io_server.websocket_port }\nhttp://13.53.185.194:${ io_server.websocket_port }/`));

// open express connection
// app.get(API.default.get_tasks.path, (req:any, res:any) => API.default.get_tasks.handler(req, res));

app.get("/check", (req:any, res:any) => res.json(
    {
        code: 200,
        status: true,
        message: "Server is running"
    }

));


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


import {server} from "./api/game/websocket";
server.listen(80, () => console.info(`Az http server fut ezen a porton: ${ 80 }\nhttp://localhost/`));