import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../animations/Waiting.dart';
import '../../../userAuth/auth_service.dart';
import '../../challengeChooser/Widgets/ChallengeChooser.dart';
import '../../home.dart';
import '../config.dart';
import '../management/matchmaking.dart';

class WaitRoom extends StatefulWidget {
  final List<String>
      playerNames; //Don't save email because it's unnecessary (privacy)
  final User user;
  final String documentId;
  final int roomID;
  const WaitRoom(
      {super.key,
      required this.playerNames,
      required this.user,
      required this.documentId,
      required this.roomID});

  @override
  State<WaitRoom> createState() => _WaitRoomState();
}

class _WaitRoomState extends State<WaitRoom> {
  RealtimeSubscription? realtimeRoomMembersSubscription;
  late List<String> playerNames;
  @override
  void initState() {
    subscribeToRoomMemberUpdate();
    playerNames = List.from(widget.playerNames);
    super.initState();
  }

  @override
  void dispose() {
    realtimeRoomMembersSubscription?.close();
    super.dispose();
  }

  void subscribeToRoomMemberUpdate() {
    final realtime = Realtime(client);

    realtimeRoomMembersSubscription = realtime.subscribe(['documents']);

    // listen to changes
    realtimeRoomMembersSubscription!.stream.listen((data) {
      final event = data.events.first;
      final payload = data.payload;
      List<String> updatedPlayerNames = List.from(playerNames);
      if (payload["room_id"] != widget.roomID) {
        return;
      }
      if (event.endsWith("create")) {
        logger.i("${payload["user_name"]} joined the room");
        updatedPlayerNames.add(payload["user_name"]);
        setState(() {
          playerNames = updatedPlayerNames;
        });
      } else if (event.endsWith("delete")) {
        if (payload["user_email"] == widget.user.email) {
          logger.i(
              "User got kicked out of Room ${payload["room_id"]} (🤫He could also have left, I have no way of knowing that 😅)");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Home(user: widget.user)));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "You got kicked out of the Matchmaking. To join a different room, try again.")));
          return;
        }
        if (!updatedPlayerNames.contains(payload["user_name"])) {
          logger.wtf(
              "${payload["user_name"]} left the room but somehow he wasn't even present in the clients memory?");
          return;
        }
        logger.i("${payload["user_name"]} left the room");
        updatedPlayerNames.remove(payload["user_name"]);
        setState(() {
          playerNames = updatedPlayerNames;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondary
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Matchmaking - Wait for other Players",
                  softWrap: true,
                  overflow: TextOverflow.visible,
                )
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: maxPlayersPerRoom,
                itemBuilder: (context, index) {
                  if (index <= playerNames.length - 1) {
                    return Card(
                      elevation: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                playerNames[index][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(playerNames[index]),
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
                          const SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              WaitingDots(),
                              const Text("Waiting for Player"),
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
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ChallengeChooser())),
              child: Text("Start Game (Debug)")),
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
