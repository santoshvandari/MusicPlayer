import 'package:path_provider/path_provider.dart';

class AudioService {
  static Future<List<String>> getLocalAudioFiles() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return [];
    final files =
        directory.listSync().where((file) => file.path.endsWith('.mp3'));
    return files.map((file) => file.path).toList();
  }
}
