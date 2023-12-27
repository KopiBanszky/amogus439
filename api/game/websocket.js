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
Object.defineProperty(exports, "__esModule", { value: true });
exports.io_server = exports.io = void 0;
const socket_io_1 = require("socket.io");
const http_1 = require("http");
const index_1 = require("../../index");
const admin_ui_1 = require("@socket.io/admin-ui");
const EVNETS = __importStar(require("./ws_exports"));
const websocket_port = 8081;
const server = (0, http_1.createServer)(index_1.app);
const io = new socket_io_1.Server(server, {
    cors: {
        origin: ["https://admin.socket.io", "http://13.53.185.194:8080", "http://13.53.185.194:8081", 'null'],
        credentials: true,
    },
});
exports.io = io;
(0, admin_ui_1.instrument)(io, {
    auth: {
        type: "basic",
        username: "lopany",
        password: "$2b$10$heqvAkYMez.Va6Et2uXInOnkCT6/uQj1brkrbyG3LpopDklcq7ZOS" // "changeit" encrypted with bcrypt
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
const io_server = { server, websocket_port };
exports.io_server = io_server;
