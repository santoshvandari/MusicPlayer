import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AudioService {
  static Future<List<String>> getLocalAudioFiles() async {
    List<String> audioFiles = [];

    try {
      // Scan multiple directories
      final directories = await _getAllMusicDirectories();

      // Supported audio file extensions
      final supportedExtensions = ['.mp3', '.wav', '.m4a', '.flac', '.ogg'];

      // Recursive file scanning
      for (var directory in directories) {
        final scannedFiles =
            await _scanDirectoryRecursively(directory, supportedExtensions);
        audioFiles.addAll(scannedFiles);
      }

      // Remove duplicates and sort
      audioFiles = audioFiles.toSet().toList();
      audioFiles.sort((a, b) => path.basename(a).compareTo(path.basename(b)));

      return audioFiles;
    } catch (e) {
      print('Error scanning audio files: $e');
      return [];
    }
  }

  static Future<List<Directory>> _getAllMusicDirectories() async {
    List<Directory> musicDirectories = [];

    try {
      // External storage directories
      final externalDir = await getExternalStorageDirectory();
      final externalDirs = await getExternalStorageDirectories();

      // Music-specific directories
      final musicDir = Directory('/storage/emulated/0/Music');
      final downloadsDir = Directory('/storage/emulated/0/Download');

      // Add non-null directories
      if (externalDir != null) musicDirectories.add(externalDir);
      if (externalDirs != null) musicDirectories.addAll(externalDirs);

      if (await musicDir.exists()) musicDirectories.add(musicDir);
      if (await downloadsDir.exists()) musicDirectories.add(downloadsDir);
    } catch (e) {
      print('Error finding music directories: $e');
    }

    return musicDirectories;
  }

  static Future<List<String>> _scanDirectoryRecursively(
      Directory directory, List<String> supportedExtensions) async {
    List<String> audioFiles = [];

    try {
      // Check if directory exists and is readable
      if (!await directory.exists()) return [];

      // Recursive directory listing
      await for (var entity
          in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(extension)) {
            audioFiles.add(entity.path);
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${directory.path}: $e');
    }

    return audioFiles;
  }
}
