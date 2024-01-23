import task_upload from "./manager/task_upload";
import get_tasks from "./manager/get_tasks";
import delete_task from "./manager/delete_task";
import join_game from "./game/join/join_game";
import create_game from "./game/host/create_game";
import update from "./game/host/settings/update";
import maps from "./manager/maps";
import getPlayer from "./game/ingame/getPlayer";
import getPlayers from "./game/ingame/getPlayers";
import getTasks from "./game/ingame/getTasks";


export default {
    task_upload,
    get_tasks,
    delete_task,
    join_game,
    create_game,
    update,
    maps,
    getPlayer,
    getPlayers,
    getTasks
}