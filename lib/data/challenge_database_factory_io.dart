import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openChallengeDatabaseImpl(String name) async {
  final directory = await getApplicationDocumentsDirectory();
  final databasePath = path.join(directory.path, name);
  return databaseFactoryIo.openDatabase(databasePath);
}
