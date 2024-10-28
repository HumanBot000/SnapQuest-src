const int maxPlayersPerRoom = 10;
const int assetDisapprovalThreshold = 5;
const Duration maxVideoDuration = Duration(seconds: 15);
const Duration gameDataDeletionThreshold = Duration(hours: 2);
const List<Duration> challengeTimeLimitsByDifficulty = [
  Duration(minutes: 1), // easy
  Duration(minutes: 3),
  Duration(minutes: 5),
  Duration(minutes: 7),
  Duration(minutes: 10), //hard
  //This might be loaded from a database, but I think for the Hackathon it's fine to hardcode it
];
