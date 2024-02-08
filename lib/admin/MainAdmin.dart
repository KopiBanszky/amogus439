import 'package:flutter/material.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          alignment: WrapAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addPoint');
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightGreen[700]),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                )),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.fromLTRB(25, 15, 25, 15)),
                side: MaterialStateProperty.all(const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                )),
                textStyle: MaterialStateProperty.all(const TextStyle(
                  fontSize: 20,
                )),
              ),
              child: const Text(
                "Add Point",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                )),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.fromLTRB(25, 15, 25, 15)),
                side: MaterialStateProperty.all(const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                )),
                textStyle: MaterialStateProperty.all(const TextStyle(
                  fontSize: 20,
                )),
              ),
              child: const Text(
                "Remove Task",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
