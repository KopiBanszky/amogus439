"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.randomNum = exports.COLORS = exports.isEmpty = void 0;
const COLORS = [10027008 /*red*/, 327777 /*blue*/, 24861 /*green*/, 16776960 /*yellow*/, 16711680 /*pink*/, 16711935 /*orange*/, 16777215 /*white*/, 0 /*black*/, /*brown*/ 6724095, /*purple*/ 10079232, /*dark blue*/ 255, /*dark red*/ 128, /*light red*/ 16711680, /*dark pink*/ 8388736, /*light pink*/ 16711935, /*dark orange*/ 10027008, /*light orange*/ 16737792, /*dark yellow*/ 8421504, /*light yellow*/ 16776960, /*dark brown*/ 32896, /*light brown*/ 6724095, /*dark purple*/ 8388736, /*light purple*/ 10079232, /*dark cyan*/ 32896, /*dark lime*/ 32768, /*dark white*/ 8421504, /*light white*/ 16777215, /*dark black*/ 128, /*light black*/ 0];
exports.COLORS = COLORS;
function isEmpty(str) {
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
