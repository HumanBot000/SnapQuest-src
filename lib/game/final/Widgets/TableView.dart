import 'package:flutter/material.dart';
import '../management/getResults.dart';
import 'package:intl/intl.dart';

class ResultsTable extends StatefulWidget {
  final int roomID;

  const ResultsTable({super.key, required this.roomID});

  @override
  State<ResultsTable> createState() => _ResultsTableState();
}

class _ResultsTableState extends State<ResultsTable> {
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    _populateSubmissions();
  }

  Future<void> _populateSubmissions() async {
    submissions = await getLinkedUsersToVideo(widget.roomID);
  }

  List<TableRow> _getTableRows() {
    List<TableRow> rows = [
      const TableRow(children: [
        Text("Rank", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Player", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Submission", style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    ];
    for (int i = 0; i < submissions.length; i++) {
      rows.add(TableRow(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${i + 1}.",
                style: TextStyle(fontSize: 30),
              ),
            ),
            i == 0
                ? const Icon(
                    size: 40,
                    Icons.emoji_events,
                    color: Color(0xffFFD700),
                  )
                : i == 1
                    ? const Icon(
                        size: 40,
                        Icons.emoji_events,
                        color: Color(0xffC0C0C0),
                      )
                    : i == 2
                        ? const Icon(
                            size: 40,
                            Icons.emoji_events,
                            color: Color(0xffCD7F32),
                          )
                        : Container(),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Text(
                  submissions[i]['userName'].substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Text(submissions[i]['userName']),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.watch_later),
            ),
            Expanded(
              child: Text(DateFormat("HH:mm:ss")
                  .format(submissions[i]['submission'].submissionTime)),
            ),
          ],
        ),
      ]));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    _populateSubmissions();
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
      body: Table(
          border: TableBorder.all(
              color: Theme.of(context).colorScheme.primary, width: 2),
          children: _getTableRows()),
    );
  }
}
