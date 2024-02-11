import { create_new_player } from "./join/ws_join";
import { create_new_game } from "./host/create_game_socket";
import disconnect from "./disconnect/ws_disconnect";
import start_vote from "./ingame/start_vote";
import vote from "./ingame/vote";
import emergency from "./ingame/emergency";
import task_done from "./ingame/task_done";
import kill from "./ingame/kill";
import report from "./ingame/report";
import start from "./host/start";
import fix_reaktor from "./ingame/sabotages/fix_reaktor";
import trigger_sabotage from "./ingame/sabotages/trigger_sabotage";
import fix_simple from "./ingame/sabotages/fix_simple";



export default {
    create_new_player,
    create_new_game,
    disconnect,
    start_vote,
    vote,
    emergency,
    task_done,
    kill,
    report,
    start,
    fix_reaktor,
    trigger_sabotage,
    fix_simple
};