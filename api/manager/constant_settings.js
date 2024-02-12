"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.settings = void 0;
exports.settings = {
    sabotage_coolwown: 10,
};
exports.default = {
    path: '/api/manager/settings',
    method: 'GET',
    handler: function (req, res) {
        res.status(200).json(exports.settings);
    }
};
