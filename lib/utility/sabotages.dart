import 'package:flutter/material.dart';

class SabotagesWidget extends StatefulWidget {
  const SabotagesWidget({super.key, required this.sabotage});

  final dynamic sabotage;

  @override
  State<SabotagesWidget> createState() => _SabotagesWidgetState();
}

class _SabotagesWidgetState extends State<SabotagesWidget> {
  dynamic sabotage;

  @override
  Widget build(BuildContext context) {
    sabotage = widget.sabotage;
    return Container(
      width: MediaQuery.of(context).size.width * .97,
      height: MediaQuery.of(context).size.height * .3,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Reaktor"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Reaktor",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Reaktor"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const ImageIcon(
                        AssetImage("assets/reactor.png"),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Lights"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fények",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Lights"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const ImageIcon(
                        AssetImage("assets/lights.png"),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Navigation"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Navigáció",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Navigation"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const ImageIcon(
                        AssetImage("assets/navigation.png"),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
