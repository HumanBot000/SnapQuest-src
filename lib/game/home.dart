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
    databases = Databases(client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Home",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary, fontSize: 24),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome ${widget.user.name}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          ElevatedButton(
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
              ))
        ],
      ),
    );
  }
}
