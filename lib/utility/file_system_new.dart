import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';

/// questa classe permette di creare un oggetto da passare in ingresso ai widget delle foto
/// per gestire la cache in modo singolo per ogni chat, appunto per la logica di separare
/// le cache
class FileSystemNew implements FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;

  FileSystemNew(this._cacheKey) : _fileDir = createDirectory(_cacheKey);

  static Future<Directory> createDirectory(String key) async {
    var baseDir = await getApplicationSupportDirectory();
    var path = p.join(baseDir.path, key);

    var fs = const LocalFileSystem();
    var directory = fs.directory((path));
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    var directory = (await _fileDir);
    if (!(await directory.exists())) {
      await createDirectory(_cacheKey);
    }
    return directory.childFile(name);
  }
}
