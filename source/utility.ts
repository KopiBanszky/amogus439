import { RequestHandlerParams, ParamsDictionary } from 'express-serve-static-core';
import { ParsedQs } from 'qs';

interface apiMethod {
    method: string,
    path: string,
    handler: any,
}

interface Geo_pos {
    latitude: number,
    longitude: number
}

interface Game {
    id: number, //game id (6 digit number)
    task_num: number, //number of tasks
    task_visible: boolean, //whether the tasks that done are visible to the players or not
    vote_time: number, //seconds
    anonymus_vote: boolean, //whether the votes are anonymus or not
    kill_cooldown: number, //seconds
    impostor_max: number, //max number of impostors
    emergencies: number, //number of emergencies can used by players
    status: number, //game status, 0: waiting for players, 1: game started, 2: voting, 3: game ended
    map: string, //map name
}

interface Player {
    id: number, //player id, autoincrement
    game_id: number, //game id (6 digit number)
    socket_id: string, //socket id
    name: string, //player name
    color: number, //player color (decimal, need to convert to hex)
    emergency: number, //number of emergencies used by player
    tasks: number[], //all tasks that player has (task ids)
    task_done: number[], //all tasks that player has done (task ids)
    team: boolean, //false: crewmate, true: impostor
    geo_pos: Geo_pos, //player location [latitude, longitude]
    dead: boolean //whether the player is dead or not
    host: boolean //whether the player is host or not
    votes: number //number of votes for this player
    voted: boolean //whether the player voted or not
}

interface Task {
    id: number, //task id, autoincrement
    name: string, //task name
    geo_pos: [string, number], //task location [latitude, longitude]
    map: string //map name
}

const COLORS: number[] = [16776960 /*yellow*/, 16711680 /*pink*/, 16711935 /*orange*/, /*brown*/ 6724095, /*purple*/ 10079232, /*light red*/ 16711680, /*dark pink*/ 8388736, /*light pink*/ 16711935, /*dark orange*/ 16737792, /*dark yellow*/ 8421504, /*light yellow*/ 16776960, /*light brown*/ 6724095, /*dark purple*/ 8388736, /*light purple*/ 10079232, /*dark white*/ 8421504];

function isEmpty(str: string): boolean {
    if(typeof str != "string") return true;
    str = str.replace(/ /g, "");
    if (str.length == 0) {
        return true;
    }
    return false;
}

function randomNum(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1) + min);
}

export {
    isEmpty,
    apiMethod,
    Game,
    Player,
    Task,
    COLORS,
    randomNum
};
