import 'package:sembast_web/sembast_web.dart';

Future<Database> openChallengeDatabaseImpl(String name) {
  return databaseFactoryWeb.openDatabase(name);
}
