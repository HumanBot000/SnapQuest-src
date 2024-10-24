import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/classes/Challenge.dart';
import 'package:appwrite_hackathon_2024/game/live/mediaApproval/management/getMedia.dart';
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import '../../../../animations/GradientText.dart';
import '../../../../enums/appwrite.dart';
import '../../../../main.dart';
import '../../../../userAuth/auth_service.dart';
import '../../Widgets/Timer.dart';
import '../management/removeMedia.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

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

// Inside your _CheckingStackState class
class _CheckingStackState extends State<CheckingStack> {
  List<Uri> mediaSeenBefore = [];
  List<Uri> mediaToValidate = [];
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
    mediaToValidate = await getMedia(widget.roomID);
    List<Uri> mediaNotSeenBefore = [];
    for (var medium in mediaToValidate) {
      if (!mediaSeenBefore.contains(medium)) {
        mediaNotSeenBefore.add(medium);
      }
    }
    setState(() {
      mediaToValidate = mediaNotSeenBefore;
    });

    // Initialize video or image for the first media
    if (mediaToValidate.isNotEmpty) {
      _isVideo = await _assetIsVideo(mediaToValidate[0]);
      if (_isVideo) {
        _videoController =
            VideoPlayerController.network(mediaToValidate[0].toString())
              ..initialize().then((_) {
                setState(() {});
                _videoController?.play();
              });
      }
    }
  }

  void _subscribeToSubmittedMediaAppend() {
    final realtime = Realtime(client);
    realtimeMediaValidationSubscription = realtime.subscribe(
        ['databases.$appDatabase.collections.$roomMediaCollection.documents']);
    // Listen to changes
    realtimeMediaValidationSubscription?.stream.listen((event) {
      print("object");
      final payload = event.payload;
      if (!event.events.first.endsWith("create") ||
          payload['room_id'] != widget.roomID) {
        return;
      }
      _updateMediaToValidate();
    });
  }

  Future<bool> _assetIsVideo(Uri uri) async {
    try {
      final response = await http.head(uri);
      if (response.headers.containsKey('content-type')) {
        final contentType = response.headers['content-type'] ?? '';
        return contentType.startsWith('video/');
      }
    } catch (e) {
      logger.e("Error occurred while fetching headers: $e");
    }
    return false;
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
                child: mediaToValidate.isNotEmpty
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
                          //todo bottomoverflow for videos
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
                                  // Display video if asset is a video, otherwise image
                                  _isVideo
                                      ? (_videoController != null &&
                                              _videoController!
                                                  .value.isInitialized)
                                          ? AspectRatio(
                                              aspectRatio: _videoController!
                                                  .value.aspectRatio,
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
                                                  mediaToValidate[0]
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
                                              widget.user, mediaToValidate[0]);
                                          logger.i("disapproved medium");
                                          Navigator.pop(context);
                                          mediaSeenBefore
                                              .add(mediaToValidate[0]);
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
                                          mediaSeenBefore
                                              .add(mediaToValidate[0]);
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
                            mediaSeenBefore.add(mediaToValidate[0]);
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

class SwipeDirectionColor {
  static const right = Color.fromRGBO(70, 195, 120, 1);
  static const left = Color.fromRGBO(220, 90, 108, 1);
}

const _labelAngle = pi / 2 * 0.2;

class CardLabel extends StatelessWidget {
  const CardLabel._({
    required this.color,
    required this.label,
    required this.angle,
    required this.alignment,
  });

  factory CardLabel.right() {
    return const CardLabel._(
      color: SwipeDirectionColor.right,
      label: 'APPROVE',
      angle: -_labelAngle,
      alignment: Alignment.topLeft,
    );
  }

  factory CardLabel.left() {
    return const CardLabel._(
      color: SwipeDirectionColor.left,
      label: 'DISAPPROVE',
      angle: _labelAngle,
      alignment: Alignment.topRight,
    );
  }

  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 36,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 4,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
