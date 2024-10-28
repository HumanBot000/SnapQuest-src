import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:SnapQuest/classes/Challenge.dart';
import 'package:SnapQuest/enums/gameConfig.dart';
import 'package:SnapQuest/game/live/mediaApproval/management/getMedia.dart';
import 'package:SnapQuest/util/DBLockup.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import '../../../../animations/GradientText.dart';
import '../../../../enums/appwrite.dart';
import '../../../../main.dart';
import '../../../../userAuth/auth_service.dart';
import '../../../../util/Files.dart';
import '../../../final/Widgets/Results.dart';
import '../../Widgets/Timer.dart';
import '../management/removeMedia.dart';
import 'package:video_player/video_player.dart';
import 'SwipeableCardConfig.dart';

class CheckingStack extends StatefulWidget {
  final Duration timeRemaining;
  final Challenge challenge;
  final User user;
  final int roomID;
  const CheckingStack(
      {super.key,
      required this.timeRemaining,
      required this.challenge,
      required this.user,
      required this.roomID});

  @override
  State<CheckingStack> createState() => _CheckingStackState();
}

class _CheckingStackState extends State<CheckingStack> {
  List<Uri> assetSeenBefore = [];
  List<Uri> assetsToValidate = [];
  int cardIndex = 0;
  RealtimeSubscription? realtimeMediaValidationSubscription;
  VideoPlayerController? _videoController;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _subscribeToSubmittedMediaAppend();
    _updateMediaToValidate();
  }

  @override
  void dispose() {
    super.dispose();
    realtimeMediaValidationSubscription?.close();
    _videoController?.dispose(); // Dispose video controller
  }

  Future<void> _updateMediaToValidate() async {
    assetsToValidate = await getMedia(widget.roomID);
    List<Uri> assetNotSeenBefore = [];
    for (var medium in assetsToValidate) {
      if (!assetSeenBefore.contains(medium)) {
        assetNotSeenBefore.add(medium);
      }
    }
    setState(() {
      assetsToValidate = assetNotSeenBefore;
    });
    if (assetsToValidate.isNotEmpty) {
      _isVideo = await assetIsVideo(assetsToValidate[0]);
      if (_isVideo) {
        _videoController = VideoPlayerController.networkUrl(assetsToValidate[0])
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
          });
      }
    }
    if (assetsToValidate.length == await userAmountInRoom(widget.roomID)) {
      //All users have submitted their asset
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  Results(user: widget.user, roomID: widget.roomID)),
          (Route route) => false);
    }
  }

  void _subscribeToSubmittedMediaAppend() {
    final realtime = Realtime(client);
    realtimeMediaValidationSubscription = realtime.subscribe(
        ['databases.$appDatabase.collections.$roomMediaCollection.documents']);
    // Listen to changes
    realtimeMediaValidationSubscription?.stream.listen((event) {
      final payload = event.payload;
      if (!event.events.first.endsWith("create") ||
          payload['room_id'] != widget.roomID) {
        return;
      }
      _updateMediaToValidate();
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
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            leading: null, //todo removal doesn't work
            title: Center(
              child: GradientText(
                "Do these Assets fulfill the given Challenge?",
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.onSecondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CountdownTimer(
            user: widget.user,
            roomID: widget.roomID,
            initialDuration: widget.timeRemaining,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "If more than 50% of Users say that this asset doesn't fulfill the challenge, it will be deleted. Please note that this isn't the place to report inappropriate content.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: assetsToValidate.isNotEmpty
                    ? SwipableStack(
                        allowVerticalSwipe: false,
                        overlayBuilder: (context, properties) {
                          final opacity = min(properties.swipeProgress, 1.0);
                          final isRight =
                              properties.direction == SwipeDirection.right;
                          final isLeft =
                              properties.direction == SwipeDirection.left;
                          logger.v(properties.direction);
                          if (isRight) {
                            return Opacity(
                              opacity: isRight ? opacity : 0,
                              child: CardLabel.right(),
                            );
                          } else if (isLeft) {
                            return Opacity(
                              opacity: isLeft ? opacity : 0,
                              child: CardLabel.left(),
                            );
                          } else {
                            logger.wtf(
                                "Wrong direction: ${properties.direction}");
                            return const SizedBox.shrink();
                          }
                        },
                        builder: (context, properties) {
                          return Align(
                            key: UniqueKey(),
                            alignment: Alignment.center,
                            child: Card(
                              elevation: 6.0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              shadowColor: Colors.grey.withOpacity(0.5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _isVideo
                                      ? (_videoController != null &&
                                              _videoController!
                                                  .value.isInitialized)
                                          ? Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              child: VideoPlayer(
                                                  _videoController!),
                                            )
                                          : const CircularProgressIndicator()
                                      : Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  assetsToValidate[0]
                                                      .toString()),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Asset #${cardIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onSwipeCompleted: (swipeIndex, direction) async {
                          if (direction == SwipeDirection.left) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Do you really want to disapprove this asset?",
                                    ),
                                    content: const Text(
                                      "Do you think this image doesn't fulfill the challenge?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          disapproveAsset(
                                              widget.user,
                                              assetsToValidate[0],
                                              widget.roomID);
                                          logger.i("disapproved medium");
                                          Navigator.pop(context);
                                          assetSeenBefore
                                              .add(assetsToValidate[0]);
                                          await _updateMediaToValidate();
                                          setState(() {
                                            cardIndex += 1;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.flag,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            const Text(
                                              "Disapprove Asset",
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          assetSeenBefore
                                              .add(assetsToValidate[0]);
                                          await _updateMediaToValidate();
                                          setState(() {
                                            cardIndex += 1;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            Text("Approve Asset"),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                });
                          } else {
                            assetSeenBefore.add(assetsToValidate[0]);
                            await _updateMediaToValidate();
                            setState(() {
                              cardIndex += 1;
                            });
                          }
                        },
                      )
                    : const Text(
                        "You have rated all assets for this game. Wait until new assets are uploaded, wait till the timer runs out or wait till everyone has uploaded one asset."),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
