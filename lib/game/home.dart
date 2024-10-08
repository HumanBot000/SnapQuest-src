import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import '../enums/appwrite.dart';
import '../userAuth/auth_service.dart';
import './matchmaking/management/matchmaking.dart' as matchmaking;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final User user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences prefs;
  bool isOutdoor = true;
  @override
  initState() {
    super.initState();
    if (!_isDatabasesInitialized()) {
      databases = Databases(client);
    }
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isOutdoor = prefs.getBool('isOutdoor') ?? true;
    });
  }

  bool _isDatabasesInitialized() {
    try {
      databases;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _toggleOutdoor(bool value) async {
    setState(() {
      isOutdoor = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOutdoor', value);
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
                onPressed: () => matchmaking.startGame(context, widget.user,
                    isOutdoor: isOutdoor),
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
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Are you currently Outside?"),
                  Spacer(),
                  Icon(
                    Icons.kitchen,
                    color: Colors.brown.shade400,
                  ),
                  AnimatedContainer(
                    margin: const EdgeInsets.only(left: 10),
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOutdoor
                            ? [
                                Theme.of(context).colorScheme.secondary,
                                Colors.green,
                              ]
                            : [
                                Theme.of(context).colorScheme.secondary,
                                Colors.brown,
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Switch(
                      value: isOutdoor,
                      onChanged: (value) => _toggleOutdoor(value),
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  Icon(
                    Icons.nature,
                    color: Colors.green,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
