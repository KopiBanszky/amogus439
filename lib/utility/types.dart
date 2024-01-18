// Dart equivalent for TypeScript interface Task
import 'dart:convert';
import 'dart:ui';

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

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      geoPos: Map<String, double>.from(map['geo_pos'].map((key, value) => MapEntry(key, value.toDouble()))),
      map: map['map'],
    );
  }
}


// Dart equivalent for TypeScript interface Game
class Game {
  final int id; // game id (6 digit number)
  int taskNumber; // number of tasks
  bool taskVisible; // whether the tasks that done are visible to the players or not
  int voteTime; // seconds
  bool anonymousVote; // whether the votes are anonymous or not
  int killCooldown; // seconds
  int impostorMax; // max number of impostors
  int emergencies; // number of emergencies can be used by players
  int status; // game status, 0: waiting for players, 1: game started, 2: voting, 3: game ended, 4: waiting for assemble
  String map; // map name

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


  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      taskNumber: map['task_num'],
      taskVisible: map['task_visibility'] == 1 ? true : false,
      voteTime: map['vote_time'],
      anonymousVote: map['anonymous_vote'] == 1 ? true : false,
      killCooldown: map['kill_cooldown'],
      impostorMax: map['impostor_max'],
      emergencies: map['emergencies'],
      status: map['status'],
      map: map['map'] ?? "Not Selected",
    );
  }
}

// Dart equivalent for TypeScript interface Player
class Player {
  final int id; // player id, autoincrement
  late final int gameId; // game id (6 digit number)
  final String socketId; // socket id
  final String name; // player name
  final Color color; // player color (decimal, need to convert to hex)
  int emergency; // number of emergencies used by player
  List<int> tasks; // all tasks that player has (task ids)
  List<int> taskDone; // all tasks that player has done (task ids)
  bool team; // false: crewmate, true: impostor
  Map<String, double> geoPos; // player location [latitude, longitude]

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

  // Factory method to create a Player object from a Map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      gameId: int.parse(map['game_id'].toString()),
      socketId: map['socket_id'],
      name: map['name'],
      color: HexColor.fromHex(map['color'].toRadixString(16)),
      emergency: map['emergency'] ?? 0,
      tasks: List<int>.from(map['tasks'] ?? []),
      taskDone: List<int>.from(map['task_done'] ?? []),
      team: map['team'] == 1 ? true : false,
      geoPos: Map<String, double>.from(map['geo_pos']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {"latitude": 0.0, "longitude": 0.0}),
    );
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}