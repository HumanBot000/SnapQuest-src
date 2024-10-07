import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import '../userAuth/auth_service.dart';
import 'matchmaking/config.dart';
import './matchmaking/management/matchmaking.dart' as matchmaking;

class Home extends StatefulWidget {
  final User user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  initState() {
    super.initState();
    if (!_isDatabasesInitialized()) {
      databases = Databases(client);
    }
  }

  bool _isDatabasesInitialized() {
    try {
      databases;
      return true;
    } catch (e) {
      return false;
    }
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
                  "Home",
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome ${widget.user.name}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                )),
                onPressed: () => matchmaking.startGame(context, widget.user),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Start Game",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    Icon(Icons.videogame_asset,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
