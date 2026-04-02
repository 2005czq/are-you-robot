import 'package:sembast/sembast.dart';

import 'challenge_database_factory_stub.dart'
    if (dart.library.io) 'challenge_database_factory_io.dart'
    if (dart.library.html) 'challenge_database_factory_web.dart';

Future<Database> openChallengeDatabase(String name) {
  return openChallengeDatabaseImpl(name);
}
