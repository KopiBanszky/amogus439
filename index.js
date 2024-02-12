"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = exports.port = void 0;
const express_1 = __importDefault(require("express"));
const body_parser_1 = __importDefault(require("body-parser"));
const cors_1 = __importDefault(require("cors"));
const API = __importStar(require("./api/exports"));
const app = (0, express_1.default)();
exports.app = app;
app.use(express_1.default.json());
app.use((0, cors_1.default)());
app.set('view engine', 'ejs');
const urlencodedParser = body_parser_1.default.urlencoded({ extended: false });
const port = 8080;
exports.port = port;
app.listen(port, () => console.info(`Az app fut ezen a porton: ${port}\nhttp://13.53.185.194:${port}/`));
app.use(express_1.default.static(__dirname + '/public'));
// io_server.server.listen(io_server.websocket_port, () => console.info(`A websocket szerver ezen a porton fut: ${ io_server.websocket_port }\nhttp://13.53.185.194:${ io_server.websocket_port }/`));
// open express connection
// app.get(API.default.get_tasks.path, (req:any, res:any) => API.default.get_tasks.handler(req, res));
app.get("/check", (req, res) => res.json({
    code: 200,
    status: true,
    message: "Server is running"
}));
for (let route of Object.values(API.default)) {
    // const route:apiMethod = API.default[i];
    console.log(route.path, route.method);
    if (route.method && route.method == 'POST') {
        app.post(route.path, urlencodedParser, route.handler);
    }
    if (route.method && route.method == 'GET') {
        app.get(route.path, route.handler);
    }
    if (route.method && route.method == 'DELETE') {
        app.delete(route.path, route.handler);
    }
    if (route.method && route.method == 'PUT') {
        app.put(route.path, route.handler);
    }
}
const websocket_1 = require("./api/game/websocket");
websocket_1.server.listen(80, () => console.info(`Az http server fut ezen a porton: ${80}\nhttp://localhost/`));
