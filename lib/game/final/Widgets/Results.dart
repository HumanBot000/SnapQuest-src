import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/game/final/Widgets/TableView.dart';
import 'package:appwrite_hackathon_2024/game/final/management/getResults.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../classes/Submission.dart';
import '../../../main.dart';
import '../../../util/DBLockup.dart';
import '../../../util/Files.dart';

class Results extends StatefulWidget {
  final int roomID;
  final User user;

  const Results({super.key, required this.roomID, required this.user});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  List<Submission> submissions = [];
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, ValueNotifier<bool>> _isVideoPlaying = {};
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int? _currentActiveIndex;

  @override
  void initState() {
    super.initState();
    _populateSubmissions();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
  }

  void _populateSubmissions() async {
    submissions = await getResults(widget.roomID);
    setState(() {
      isLoading = false;
      submissions = submissions;
    });
  }

  Future<void> _initializeVideoController(int index, Uri url) async {
    if (!_videoControllers.containsKey(index)) {
      _videoControllers[index] = VideoPlayerController.networkUrl(url);
      await _videoControllers[index]?.initialize();
      await _videoControllers[index]?.setLooping(true);
      _isVideoPlaying[index] = ValueNotifier(false);
    }
  }

  void _togglePlayPause(int index) {
    if (_currentActiveIndex != null && _currentActiveIndex != index) {
      _isVideoPlaying[_currentActiveIndex!]?.value = false;
      _videoControllers[_currentActiveIndex!]?.pause();
    }
    final isPlaying = _isVideoPlaying[index]?.value ?? false;
    _isVideoPlaying[index]?.value = !isPlaying;
    if (!isPlaying) {
      _videoControllers[index]?.play();
      _currentActiveIndex = index;
    } else {
      _videoControllers[index]?.pause();
      _currentActiveIndex = null;
    }
  }

  void _handleScroll() {
    for (int index = 0; index < submissions.length; index++) {
      if (_videoControllers.containsKey(index)) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          double videoPosition = box.localToGlobal(Offset.zero).dy;
          double screenHeight = MediaQuery.of(context).size.height;

          if (videoPosition > 0 && videoPosition < screenHeight) {
            if (_currentActiveIndex == null || _currentActiveIndex != index) {
              _togglePlayPause(index);
            }
          } else if (_isVideoPlaying[index]?.value == true) {
            _isVideoPlaying[index]?.value = false;
            _videoControllers[index]?.pause();
            if (_currentActiveIndex == index) _currentActiveIndex = null;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: PreferredSize(
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
                    "Results",
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? Column(
                  children: [
                    Text("No one has submitted anything ):",
                        style: Theme.of(context).textTheme.titleMedium),
                    ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultsTable(
                                roomID: widget.roomID,
                                user: widget.user,
                              ),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Continue",
                                style: Theme.of(context).textTheme.titleMedium),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.greenAccent,
                            ),
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                        ))
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () async => _populateSubmissions(),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: submissions.length,
                        itemBuilder: (context, index) {
                          final submission = submissions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  FutureBuilder<bool>(
                                    future: assetIsVideo(submission.mediaURL),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          height: 200,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data == true) {
                                        _initializeVideoController(
                                            index, submission.mediaURL);
                                        return ValueListenableBuilder<bool>(
                                          valueListenable:
                                              _isVideoPlaying[index] != null
                                                  ? _isVideoPlaying[index]!
                                                  : ValueNotifier(false),
                                          builder: (context, isPlaying, child) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  _togglePlayPause(index),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: AspectRatio(
                                                      aspectRatio:
                                                          _videoControllers[
                                                                      index]
                                                                  ?.value
                                                                  .aspectRatio ??
                                                              16 / 9,
                                                      child: VideoPlayer(
                                                          _videoControllers[
                                                              index]!),
                                                    ),
                                                  ),
                                                  Icon(
                                                    isPlaying
                                                        ? Icons
                                                            .pause_circle_filled
                                                        : Icons
                                                            .play_circle_fill,
                                                    color: Colors.white70,
                                                    size: 64,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          submission.mediaURL.toString(),
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width: double.infinity,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        FutureBuilder<String>(
                                          future: submissionToUsername(
                                              submission.documentID),
                                          builder: (context, snapshot) {
                                            String initials = snapshot.hasData
                                                ? snapshot.data![0]
                                                    .toUpperCase()
                                                : "?";
                                            return CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.blue,
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Row(
                                          children: [
                                            FutureBuilder<String>(
                                              future: submissionToUsername(
                                                  submission.documentID),
                                              builder: (context, snapshot) {
                                                return Text(
                                                  snapshot.data ??
                                                      "Unknown User",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                );
                                              },
                                            ),
                                            index == 0
                                                ? Icon(
                                                    Icons.emoji_events,
                                                    color: Color(0xffFFD700),
                                                  )
                                                : index == 1
                                                    ? Icon(
                                                        Icons.emoji_events,
                                                        color:
                                                            Color(0xffC0C0C0),
                                                      )
                                                    : index == 2
                                                        ? Icon(
                                                            Icons.emoji_events,
                                                            color: Color(
                                                                0xffCD7F32),
                                                          )
                                                        : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsTable(
                                  roomID: widget.roomID,
                                  user: widget.user,
                                ),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Continue",
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.greenAccent,
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                          ))
                    ],
                  ),
                ),
    );
  }
}
