"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.randomNum = exports.COLORS = exports.isEmpty = void 0;
const COLORS = [16776960 /*yellow*/, 16711680 /*pink*/, 16711935 /*orange*/, /*brown*/ 6724095, /*purple*/ 10079232, /*light red*/ 16711680, /*dark pink*/ 8388736, /*light pink*/ 16711935, /*dark orange*/ 16737792, /*dark yellow*/ 8421504, /*light yellow*/ 16776960, /*light brown*/ 6724095, /*dark purple*/ 8388736, /*light purple*/ 10079232, /*dark white*/ 8421504];
exports.COLORS = COLORS;
function isEmpty(str) {
    if (typeof str != "string")
        return true;
    str = str.replace(/ /g, "");
    if (str.length == 0) {
        return true;
    }
    return false;
}
exports.isEmpty = isEmpty;
function randomNum(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}
exports.randomNum = randomNum;
