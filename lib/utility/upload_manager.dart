import 'dart:collection';
import 'dart:io';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';

/// questa classe gestisce tutto l'apparato dell'upload, si tratta di una classe globale
/// in cui l'istanza viene conservata nell'utility
class UploadManager {
  /// questa e' la lista degli upload che non sono ancora terminati
  List<ProgressFile> _listProgressFile = [];
  Queue<ProgressFile> queueNotSent = Queue<ProgressFile>();

  /// quando viene aggiunto un nuovo file da caricare, viene creato un progressFile
  /// per il corrispondente file che servirà per ottenere tutte le informazioni
  /// sullo stato dell'upload
  ProgressFile uploadFile(File file, int idAppuntamento, String idChat, int typeUpload) {
    DateTime now = new DateTime.now();
    /// qui viene generato l'url che verrà poi usato anche dal server per conservare il file
    /// questo passaggio è molto importante in quanto conoscere già il path del file
    /// prima ancora che venga realmente creato permette di anticipare il caching del file
    /// in questo modo il file sarà già disponibile all'utilizzo dell'utente prima ancora che questo
    /// esista effettivamente sul web server
    String nameUrl = Utility.getRandomString(100);


    /// il progress file, genera l'istanza che effettivamente si occupa di fare l'upload del file
    /// una volta che è stata generata questa istanza viene aggiunta nella lista dei file che sono in corso
    /// di upload o che comunque dovranno essere caricati
    /// il sistema prevede di fare l'upload solo di un file alla volta, perciò gli altri file
    /// vengono messi in coda, come si può vedere infatti solo se _listProgressFile.length == 1, cioè
    /// solo se la lista dei progressi contiene il progress che è appena stato creato, viene
    /// lanciato l'upload, altrimenti viene messo in coda
    ProgressFile progressFile = new ProgressFile(idAppuntamento, idChat, now, file, nameUrl, typeUpload);
    _listProgressFile.add(progressFile);

    if (_listProgressFile.length == 1) {
      _uploadFile(progressFile);
    } else {
      queueNotSent.add(progressFile);
    }

    return progressFile;
  }

  /// lista dei progressFile attivi per una determinata chat
  List<ProgressFile> getListProgressFile(int idAppuntamento) {
    return _listProgressFile.where((element) {
      return element.idAppuntamento == idAppuntamento;
    }).toList();
  }

  /// mentre l'upload è in corso, viene passato il valore dello stato dell'upload
  /// a un listener aggiunto dalla chatpage che ha richiesto l'upload
  /// così da mostrare l'avanzamento
  /// come si può vedere, una volta terminato, viene lanciato l'upload dei file in coda
  /// viene passato anche il datetime dell'inizio upload, così da non creare disordine nella chat
  void _uploadFile(ProgressFile progressFile) async {
    Dio dio = Dio();

    dio.post(
      EndPoint.getUrlKey(EndPoint.SEND_FILES) +
          "&datetime=${progressFile.dateTime.toString()}&id_appuntamento=${progressFile.idAppuntamento}&name=${progressFile.nameUrl}",
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(progressFile.file.path, filename: progressFile.getNameFile())
      }),
      onSendProgress: (int sent, int total) {
        progressFile.setProgress((sent/total*100).toInt());
        if(sent~/total == 1) {
          _listProgressFile.remove(progressFile);
          if (queueNotSent.isNotEmpty) {
            _uploadFile(queueNotSent.removeFirst());
          }
        }
      },
    );
  }
}

class ProgressFile {
  final int idAppuntamento;
  final String idChat;
  final DateTime dateTime;
  final File file;
  final String nameUrl;
  int progress = 0;
  Function(int) listenerProgress;
  final int typeUpload; // 0-> immagine, 1->video, 2->file

  ProgressFile(this.idAppuntamento, this.idChat, this.dateTime, this.file,
      this.nameUrl, this.typeUpload);

  void setListener(Function(int) listener) {
    listenerProgress = listener;
  }

  void delListener() {
    listenerProgress = null;
  }

  void setProgress(int progressFile) {
    progress = progressFile;
    if (listenerProgress != null) {
      listenerProgress(progress);
    }
  }

  String getNameFile() {
    return basename(file.path);
  }

  String getUrl() {
    return EndPoint.getUrl(EndPoint.UPLOAD) + nameUrl + extension(file.path);
  }

  String getExtension() {
    // "extension-file: " + extension(file.path).substring(1));
    return extension(file.path).substring(1);
  }

  bool get isVideo {
    return getExtension() == "mp4";
  }
}
