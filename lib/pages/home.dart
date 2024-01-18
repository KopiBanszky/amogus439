import 'dart:convert';
import 'dart:ffi';

import 'package:amogusvez2/connections/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../connections/socketio.dart';
import '../utility/alert.dart';

enum BtnTap {join, create}


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool connectionAvailable = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  @override
  void initState(){
    checkConnection().then((available) => {
      if(available) {
        setState(() {
          connectionAvailable = true;
        })
      }
      else {
        print("Connection unavailable")
      }


    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Image.asset("assets/background.jpg"),

          //if network or server not available, show it
          if(!connectionAvailable) Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text("Nem sikerült kapcsolódni az szerverhez...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      initState();
                    },
                    icon: const Icon(Icons.refresh,
                      color: Colors.blue,
                      size: 100,
                    ),
                  )
                )
              ],
            ),
          ),

          const SizedBox(height: 20,),

          //if connection available, show text inputs and btns
          //first two element in the column are text and number inputs (name, roomid)

          if(connectionAvailable)  Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Név",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 18,),

                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Only numbers can be entered
                  controller: roomController,
                  decoration: const InputDecoration(
                    hintText: "Szoba kód",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 18,),

                //btns to join or host game
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => validateBtn(BtnTap.join),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      child: const Text("Csatlakozás",
                        style: TextStyle(
                          color: Colors.white,
                        )
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => validateBtn(BtnTap.create),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      child: const Text("Létrehozás",
                        style: TextStyle(
                          color: Colors.white,
                        )
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }


  //pings the server, to check if its available
  Future<bool> checkConnection() async {
    try{
      RquestResult res = await http_get("/check");
      if(res.ok){
        return true;
      }
      else return false;
    }
    catch(e){
      return false;
    }

  }


  //checks witch btn is pressed, and if the needed values are valid
  void validateBtn(BtnTap btn) {
    if (btn == BtnTap.join) {
      if (
        nameController.text.trim() == "" ||
        roomController.text.trim() == "" ||
        roomController.text.trim().length != 6 ||
        nameController.text.trim().length > 20 ||
        nameController.text.trim().length < 3)
      {
        showAlert(
            "Hiba",
            "Hibás adatok!",
            Colors.red,
            true, (){}, "Ok",
            false, (){}, "",
            context
        );
      }
      else {
        joinRoom();
      }
    }
    else {
      if (
        nameController.text.trim() == "" ||
        nameController.text.trim().length > 20 ||
        nameController.text.trim().length < 3)
      {
        showAlert(
            "Hiba",
            "Hibás adatok!",
            Colors.red,
            true, (){}, "Ok",
            false, (){}, "",
            context
        );
      }
      else {
        createRoom();
      }
    }
  }



  void joinRoom() async {
    RquestResult res = await http_post("api/game/join/join_game", {
      "username": nameController.text,
      "game_id": roomController.text
    });

    Map<String, dynamic> data = jsonDecode(res.data);
    
    if(!res.ok){
      showAlert("Internal server error", "There was an error, and got no response", Colors.red, false, () {}, "", true, () {}, "Ok", context);
      return;
    }


    if(data is String) {
      showAlert("Error", "Internal Server error - 505", Colors.red, false, () {}, "", true, () {}, "Ok", context);
      return;
    }


    if(data["ok"]){
      IO.Socket socket = await connectToWebsocket();
      socket.emit("join_game", {
        "name": nameController.text,
        "game_id": roomController.text
      });
      socket.on("join_game", (msg) {
        print(jsonDecode(msg));

      });
    }
    else {
      showAlert("Hiba", data["message"], Colors.red, false, () {}, "", true, () {}, "Ok", context);
    }

  }

  void createRoom() async {
    RquestResult res = await http_post("api/game/host/create_game", {
      "username": nameController.text,
    });

    Map<String, dynamic> data = jsonDecode(res.data);

    if(!res.ok){
      showAlert("Internal server error", "There was an error, and got no response", Colors.red, false, () {}, "", true, () {}, "Ok", context);
      return;
    }


    if(data is String) {
      showAlert("Error", "Internal Server error - 505", Colors.red, false, () {}, "", true, () {}, "Ok", context);
      return;
    }



    IO.Socket socket = await connectToWebsocket();
    socket.emit("create_game", {
      "name": nameController.text,
      "game_id": data["game_id"]
    });
    socket.on("create_game", (msg) {
      print(jsonDecode(msg));

    });

  }
}
