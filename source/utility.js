"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.randomNum = exports.COLORS = exports.isEmpty = void 0;
const COLORS = [
    16776960 /*yellow*/,
    16711680 /*red*/,
    16711935 /*pink*/,
    3094773  /*blue*/, 
    10079232 /*lime*/,
    8388736  /*purple*/,
    16737792 /*orange*/,
    8421504  /*grey*/,
    1077254  /*green*/,
    7354630  /*brown*/,
    313033   /*aqua*/,
    15592941 /*white*/,
    1295001  /*turkiz?idk*/,
    5242779  /*ocsmanyzold*/,
    3484976,
    6776917,
    2960168,
    3089190,
    

];
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
