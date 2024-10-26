import 'package:appwrite/models.dart';
import 'package:appwrite_hackathon_2024/game/final/management/getResults.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../classes/Submission.dart';
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
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _populateSubmissions();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
  }

  void _populateSubmissions() async {
    submissions = await getResults(widget.roomID);
    setState(() {
      submissions = submissions;
    });
  }

  Future<void> _initVideoPlayer(Uri url) async {
    _videoController = VideoPlayerController.networkUrl(url);
    await _videoController?.initialize();
    await _videoController?.setLooping(true);
    await _videoController?.setVolume(1.0);
    await _videoController?.play();
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
                  "Let's look at the results!",
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
      body: submissions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: FutureBuilder<bool>(
                        future: assetIsVideo(submission.mediaURL),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasData && snapshot.data == true) {
                            _initVideoPlayer(submission.mediaURL);
                            return Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: VideoPlayer(_videoController!),
                              ),
                              CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: FutureBuilder(
                                      future: submissionToUsername(
                                          submission.documentID),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(".");
                                        }
                                        return Text(snapshot.data
                                            .toString()[0]
                                            .toUpperCase());
                                      }))
                            ]);
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              submission.mediaURL.toString(),
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          );
                        }),
                  ),
                );
              },
            ),
    );
  }
}
