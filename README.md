# Amogus API

### packages:
1. socket.io

### types
```ts
interface Task {
    id: number, //task id, autoincrement
    name: string, //task name
    geo_pos: [string, number], //task location [latitude, longitude]
    map: string //map name
}

interface Game {
    id: number, //game id (6 digit number)
    task_number: number, //number of tasks
    task_visible: boolean, //whether the tasks that done are visible to the players or not
    vote_time: number, //seconds
    anonymus_vote: boolean, //whether the votes are anonymus or not
    kill_cooldown: number, //seconds
    impostor_max: number, //max number of impostors
    emergencies: number, //number of emergencies can used by players
    status: number, //game status, 0: waiting for players, 1: game started, 2: voting, 3: game ended, 4: waiting for assamble
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
    geo_pos: [string, number] //player location [latitude, longitude]
}
```

---
> **POST**: api/manager/task_upload

expected data:
```ts
{
    task_name: <string:50>,
    geo_pos: <lat: <double>, lon: <double>>,
    map: <string:50> //Map name
}
Err 400 -> Empty value
```

---
> **DELETE**: api/manager/delete_task

expected data:
```ts
{
    task_id: <int>
}

Err 400 -> Null value
```

---
>**GET**: api/manager/get_tasks

response:
```ts
{
    message: <Task[]>
}
```

---
> **POST**: /api/game/host/create_game

Expected data:
```ts
{
    username: <string>
}
```
response:
```ts
{
    message: <string>,
    game_id: <number>
}
```

---
>**POST**: /api/game/join/join_game

Expected data:
```ts
{
    username: <string>,
    game_id: <number>
}
```
Res:
```ts
{
    message: <string>,
    ok: <boolean>
}
```

---
> **PUT** api/game/host/settings/update

Expected data:
```ts
{
    game_id: <number>, //required
    user_id: <number>, //required
    task_num: <number>, //optional
    task_visibility: <boolean>, //optional
    vote_time: <number>, //optional, sec
    anonymus_vote: <boolean>, //optional
    kill_cooldown: <number>, //optional, sec
    impostor_max: <number>, //optional
    emergencies: <number>, //optional
    map: <string>, //optional, map name
}
```
res
```ts
{
    message: <string>
}
```

---
> **GET**: /api/manager/maps

res
```ts
{
    message: <string>,
    maps: {map: <string>}[]
}
```

---
>**GET** /api/game/ingame/getPlayer?

Expected query:
```ts
{
    socket_id: <string>,
    user_id: <number>
    // one of them is required
}
```
res:
```ts
{
    message: <string>,
    player: <Player|undefined> //undefined if error
}
```

---
> **GET** /api/game/ingame/getPlayers

Expected query:
```ts
{
    game_id: <number> //required
}
```

res:
```ts
{
    message: <string>
    players: <Player[]|undefined> //undefined if error
}
```

# Websockets
## Server event listeners
> create_game

First it needs to be validated with the `/api/game/host/create_game` POST method.\
If it returns with 200 status, the `create_game` event can be emited.

Expected data:
```ts
{
    game_id: <number>,
    username: <string>
}
```

---
> join_game

First it needs to be validated with the `/api/game/join/join_game` POST method.\
If it returns with 200 status, the `join_game` event can be emited.

Expected data:
```ts
{
    game_id: <number>
    name: <string>
}
```

---
> start_game

Only game host: <Player> can emit it with valid return value

Expected data:
```ts
{
    game_id: <number>,
    user_id: <numbery>,
}
```

---
> start_vote

Only game host: <Player> can emit it with valid return value

Expected data:
```ts
{
    game_id: <number>,
    user_id: <number>
}
```

---
> vote

Expected data:
```ts
{
    game_id: <number>,
    user_id: <number>,
    vote_id: <number>, //player id to vote for, -1 to skip
}
```

---
> kill

Expected data:
```ts
{
    game_id: <number>,
    user_id: <number>,
    target_id: <number>
}
```

---
> task_done

Expected data:
```ts
{
    game_id: <number>,
    user_id: <number>,
    task_id: <number>
}
```

---
> report

Expected data:
```ts
{
    game_id: <number>,
    player_id: <number>, //player who reported
    dead_id: <number> //dead player
}
```

---
> emergency

Expected data:
```ts
{
    game_id: <number>,
    player_id: <number>, //player who called meeting
}
```

## Server emits

> player_disconnected

res
```ts
{
    id: <number>, //player id
    socket_id: <string>, //disconnected players socket id
    username: <string>,
}
```

---
> create_game

res:
```ts
{
    code: <number>, //status code
    message: <string>,
    data: {
        game: <Game>,
        player: <Player>
    }
}
```

---
> join_game

res: 
```ts
{
    code: <number>, //status code
    message: <string>,
    players: <Player[]>
}
```

---
> update_players

res:
```ts
{
    username: <string>,
    color: <number>,
    socket_id: <string>,
    id: <number>
}
```

---
> start_game

res:
```ts
{
    code: <number>,
    message: <string>
}
```

---
> role_update

res:
```ts
{
    player: <Player>,
    impostors: <number[]>, //the ids of the impostors
}
```

---
>game_started
```ts
{
    code: <number>,
    message: <string>
}
```

---
> start_vote

Emitted after the `start_vote` listener triggerd.

res:
```ts
{
    code: <number>,
    message: <string>,
    vote_time: <number>, //in secounds
}
```

---
> vote

Emitted as a response for listener `vote`.

res:
```ts
{
    code: <number>, //success on 200
    message: <string>
}
```

---
> vote_placed

Should listen constant when voting is started.\
Returns with any votes that placed to all player.

res:
```ts
{
    code: <number>,
    message: <string>,
    voter: <Player|number>, //if voting is anonim, it returns with -1
    voted: <Player|number>, //vote is skip, returns with -1
}
```

---
> vote_result

Emitted if voting time is over (by the server) or if all alive players have voted.\
Should listen constantly during voting.

res:
```ts
{
    code: <number>, //200 success
    message: <string>,
    skip: <boolean>,
    player: <Player|number> //player type if a player got out voted, -1 if skip
}
```

---
> kill

Emitted as a response to listener `kill`.\
res:
```ts
{
    code: <number>,
    message: <string>
}
```

---
> got_killed

Emitted to the player who got killed\
Should listen to it constantly.
```ts
{
    player:<Player> //the impostor, who killed
}
```

---
> game_end

Emitted when the server calculates that one of the team has won.\
It triggerd by listener `kill`, `disconnect`, `task_done` and `vote`.
```ts
{
    code: <number>, //200 when crewmates won, 201 when impostors won
    message: <string>, 
    impostors: <Player[]>, //list of the impostors.
}
```

---
> task_done

Emitted as a response for listener `task_done`
```ts
{
    code: <number>, //200 when success
    message: <string>
}
```

---
> task_done_by_crew

Emitted to players in game if the `task_visible` option is on true.
```ts
{
    player_id: <number>, //player who did task
    task_id: <number> 
}
```

---
> report

Emitted as a response for listener `report`
```ts
{
    code: <number>, //success on 200
    message: <string>
}
```

---
> reported_player

Emitted to all player.\
Game stops, but players can't vote.\
The host player has to trigger the `start_vote` event.
```ts
{
    message: <string>,
    reporter: <Player>, //player who reported the dead player
    reported: <Player> //dead player
}
```

---
> emergency

Emitted as a response for listener `emergency`
```ts
{
    code: <number>, //success on 200
    message: <string>
}
```

---
> emergency_called

Emitted to all player.\
Game stops, but players can't vote.\
The host player has to trigger the `start_vote` event.
```ts
{
    message: <string>,
    reporter: <Player>, //player who called the meeting
}
```


### TODOs

1. sabotages
    - communication [can't see task and map] => [reconnect to wifi with some stupid task]
    - electrics [can't call emergency meeting] => [idk]
    - hacks [impostor can see players on map] => [players have to solve some basic math task]
        - 1  `.1 .45 .65`
        - 2  `.1 .65 .3`
        - 3  `.1 .65 .43`
        - 4  `.3 .65 .1`

    - something that kills players [counter]

1. cam system
    - player can see other players for 5sec and others can see that someone is on cams
    - cooldown: 2min

1. task
    - visula tasks? idk how to create them
    - Available to make doual task, like download/upload

1. color settings for players
    - preloaded colors



---
API by **`Bánszky Koppány`**
