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
exports.server = exports.io = void 0;
const socket_io_1 = require("socket.io");
const http_1 = __importDefault(require("http"));
const index_1 = require("../../index");
const admin_ui_1 = require("@socket.io/admin-ui");
const EVNETS = __importStar(require("./ws_exports"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
//-----PRODUCTION-----
const https = require("https");
const fs = require("fs");
const key = fs.readFileSync("./private.key");
const cert = fs.readFileSync("./certificate.crt");

const cred = {
        key,
        cert
};

const server = https.createServer(cred, index_1.app);
//-----PRODUCTION-----
//----DEVELOPMENT-----
// const server = http_1.default.createServer(index_1.app);
exports.server = server;
//----DEVELOPMENT-----
const io = new socket_io_1.Server(server, {
    cors: {
        origin: ["https://admin.socket.io", "http://192.168.1.69:8081", "http://192.168.1.69:8081", "http://192.168.1.69", 'null', '*'],
        credentials: true,
    },
    transports: ['websocket', 'polling'],
});
exports.io = io;
(0, admin_ui_1.instrument)(io, {
    auth: {
        type: "basic",
        username: process.env.ADMIN_NAME || "admin",
        password: process.env.ADMIN_PASS || "admin",
    },
    mode: "development"
});
io.on('connection', (socket) => {
    console.log('a user connected, id: ' + socket.id);
    for (let route of Object.values(EVNETS.default)) {
        if (route.event) {
            socket.on(route.event, (args) => route.callback(args, socket));
        }
    }
    return socket;
});
io.engine.on("connection_error", (err) => {
    console.log(err);
});
// const io_server = {server, websocket_port};
// export {
//   io,
//   io_server,
// };
