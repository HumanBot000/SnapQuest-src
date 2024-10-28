import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../animations/Waiting.dart';
import '../../../classes/Challenge.dart';
import '../../../enums/appwrite.dart';
import '../../../userAuth/auth_service.dart';
import '../../challengeChooser/Widgets/ChallengeChooser.dart';

import '../../challengeChooser/Widgets/management/getChallenges.dart';
import '../../final/management/clean.dart';
import '../../home.dart';
import '../../../enums/gameConfig.dart';
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
    super.initState();
    playerNames = List.from(widget.playerNames);
    subscribeToRoomMemberUpdate();
    if (playerNames.contains(widget.user.name) &&
        playerNames.length >= maxPlayersPerRoom) {
      // User is already in the room and the room is ful
      isNavigatingAfterFullRoom = true;
      roomIsOutdoor(widget.roomID).then((isOutdoor) {
        return getChallenges(isOutdoor: isOutdoor);
      }).then((challenges) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeChooser(
              roomID: widget.roomID,
              user: widget.user,
              challenges: challenges,
            ),
          ),
        );
      }).catchError((error) {
        logger.e("Failed to get room or challenge data: $error");
      }).whenComplete(() {
        isNavigatingAfterFullRoom = false;
      });
    }
  }

  @override
  void dispose() {
    realtimeRoomMembersSubscription?.close();
    super.dispose();
  }

  bool isNavigatingAfterFullRoom = false;

  void subscribeToRoomMemberUpdate() {
    final realtime = Realtime(client);

    realtimeRoomMembersSubscription = realtime.subscribe([
      "databases.$appDatabase.collections.$matchmakingCollection.documents"
    ]);

    // Listen to changes
    realtimeRoomMembersSubscription!.stream.listen((data) {
      final event = data.events.first;
      final payload = data.payload;
      List<String> updatedPlayerNames = List.from(playerNames);

      if (payload["room_id"] != widget.roomID) {
        return;
      }
      if (event.endsWith("create")) {
        logger.i("${payload["user_name"]} joined the room");
        if (!updatedPlayerNames.contains(payload["user_name"])) {
          updatedPlayerNames.add(payload["user_name"]);
          setState(() {
            playerNames = updatedPlayerNames;
          });
        }
        if (!isNavigatingAfterFullRoom &&
            playerNames.length >= maxPlayersPerRoom) {
          lockRoom(widget.roomID);
          isNavigatingAfterFullRoom = true;
          roomIsOutdoor(widget.roomID).then((isOutdoor) {
            return getChallenges(isOutdoor: isOutdoor);
          }).then((challenges) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChallengeChooser(
                  roomID: widget.roomID,
                  user: widget.user,
                  challenges: challenges,
                ),
              ),
            );
          }).catchError((error) {
            logger.e("Failed to get room or challenge data: $error");
          }).whenComplete(() {
            isNavigatingAfterFullRoom = false;
          });
        }
      } else if (event.endsWith("delete")) {
        if (payload["user_email"] == widget.user.email) {
          logger.i(
              "User got kicked out of Room ${payload["room_id"]} (could have left as well)");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(user: widget.user)),
          );
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "You got kicked out of the Matchmaking. To join a different room, try again."),
          ));

          return;
        }
        if (updatedPlayerNames.contains(payload["user_name"])) {
          logger.i("${payload["user_name"]} left the room");
          updatedPlayerNames.remove(payload["user_name"]);
          setState(() {
            playerNames = updatedPlayerNames;
          });
        } else {
          logger.wtf(
              "${payload["user_name"]} left the room but wasn't in the client memory.");
        }
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
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureBuilder<bool>(
                    future: roomIsOutdoor(widget.roomID),
                    builder: (context, outdoorSnapshot) {
                      if (outdoorSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Scaffold(
                          appBar:
                              AppBar(title: const Text("Loading Room Info")),
                          body:
                              const Center(child: CircularProgressIndicator()),
                        );
                      } else if (outdoorSnapshot.hasError) {
                        logger.e("Error: ${outdoorSnapshot.error}");
                        return Scaffold(
                          appBar: AppBar(title: const Text("Error")),
                          body: Center(
                              child: Text('Error: ${outdoorSnapshot.error}')),
                        );
                      } else if (outdoorSnapshot.hasData) {
                        logger.i("Room is Outdoor: ${outdoorSnapshot.data}");
                        lockRoom(widget.roomID);
                        return FutureBuilder<List<Challenge>>(
                          future:
                              getChallenges(isOutdoor: outdoorSnapshot.data!),
                          builder: (context, challengeSnapshot) {
                            if (challengeSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Scaffold(
                                appBar: AppBar(
                                    title: const Text("Loading Challenges")),
                                body: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            } else if (challengeSnapshot.hasError) {
                              logger.e("Error: ${challengeSnapshot.error}");
                              return Scaffold(
                                appBar: AppBar(title: const Text("Error")),
                                body: Center(
                                    child: Text(
                                        'Error: ${challengeSnapshot.error}')),
                              );
                            } else if (challengeSnapshot.hasData &&
                                challengeSnapshot.data!.isNotEmpty) {
                              return ChallengeChooser(
                                roomID: widget.roomID,
                                user: widget.user,
                                challenges: challengeSnapshot.data!,
                              );
                            } else {
                              logger.w("No challenges available");
                              return Scaffold(
                                appBar: AppBar(
                                    title: const Text("No Challenges Found")),
                                body: const Center(
                                    child: Text('No challenges available')),
                              );
                            }
                          },
                        );
                      } else {
                        return Scaffold(
                          appBar:
                              AppBar(title: const Text("Room Info Not Found")),
                          body: const Center(
                              child: Text('Room information not available')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            child: const Text("Start Game (Debug)"),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.red.shade300)),
              onPressed: () {
                removePlayerFromRoom(context, widget.documentId);
                logger.d("Navigating Home");
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
