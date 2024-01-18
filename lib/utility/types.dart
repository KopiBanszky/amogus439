// Dart equivalent for TypeScript interface Task
class Task {
  final int id; // task id, autoincrement
  final String name; // task name
  final Map<String, double> geoPos; // task location [latitude, longitude]
  final String map; // map name

  Task({
    required this.id,
    required this.name,
    required this.geoPos,
    required this.map,
  });
}


// Dart equivalent for TypeScript interface Game
class Game {
  final int id; // game id (6 digit number)
  final int taskNumber; // number of tasks
  final bool taskVisible; // whether the tasks that done are visible to the players or not
  final int voteTime; // seconds
  final bool anonymousVote; // whether the votes are anonymous or not
  final int killCooldown; // seconds
  final int impostorMax; // max number of impostors
  final int emergencies; // number of emergencies can be used by players
  final int status; // game status, 0: waiting for players, 1: game started, 2: voting, 3: game ended, 4: waiting for assemble
  final String map; // map name

  Game({
    required this.id,
    required this.taskNumber,
    required this.taskVisible,
    required this.voteTime,
    required this.anonymousVote,
    required this.killCooldown,
    required this.impostorMax,
    required this.emergencies,
    required this.status,
    required this.map,
  });
}

// Dart equivalent for TypeScript interface Player
class Player {
  final int id; // player id, autoincrement
  final int gameId; // game id (6 digit number)
  final String socketId; // socket id
  final String name; // player name
  final int color; // player color (decimal, need to convert to hex)
  final int emergency; // number of emergencies used by player
  final List<int> tasks; // all tasks that player has (task ids)
  final List<int> taskDone; // all tasks that player has done (task ids)
  final bool team; // false: crewmate, true: impostor
  final Map<String, double> geoPos; // player location [latitude, longitude]

  Player({
    required this.id,
    required this.gameId,
    required this.socketId,
    required this.name,
    required this.color,
    required this.emergency,
    required this.tasks,
    required this.taskDone,
    required this.team,
    required this.geoPos,
  });
}
