"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
exports.default = {
    path: '/api/manager/login',
    method: 'POST',
    handler: function (req, res) {
        const { password } = req.body;
        if (password === process.env.MANAGER_PASS) {
            res.status(200).send({
                ok: true,
                message: 'Login successful',
            });
            return 200;
        }
        else {
            res.status(403).send({
                ok: false,
                message: 'Login failed',
            });
            return 403;
        }
    }
};
