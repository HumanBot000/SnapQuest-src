import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../animations/waiting.dart';
import '../../home.dart';
import '../config.dart';
import '../management/matchmaking.dart';

class WaitRoom extends StatefulWidget {
  final List<String>
      playerNames; //Don't save email because it's unnecessary (privacy)
  final User user;
  final String documentId;
  const WaitRoom(
      {super.key,
      required this.playerNames,
      required this.user,
      required this.documentId});

  @override
  State<WaitRoom> createState() => _WaitRoomState();
}

class _WaitRoomState extends State<WaitRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                "Matchmaking - Wait for other Players",
                softWrap: true,
                overflow: TextOverflow.visible,
              )
            ],
          )),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: maxPlayersPerRoom,
                itemBuilder: (context, index) {
                  if (index <= widget.playerNames.length - 1) {
                    return Card(
                      elevation: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                widget.playerNames[index][0],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(widget.playerNames[index]),
                          ],
                        ),
                      ),
                    );
                  }
                  return Card(
                    elevation: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(
                                    (math.Random().nextDouble() * 0xFFFFFF)
                                        .toInt())
                                .withOpacity(1.0),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              WaitingDots(),
                              Text("Waiting for Player"),
                              // Add the animated dots here
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.red.shade300)),
              onPressed: () {
                removePlayerFromRoom(context, widget.documentId);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(user: widget.user)));
              },
              child: Row(
                children: [
                  Icon(
                    Icons.door_front_door_outlined,
                    color: Color(Colors.brown.value),
                  ),
                  Text(
                    "Leave Matchmaking",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
