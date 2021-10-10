import 'dart:collection';
import 'dart:io';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:multipart_request/multipart_request.dart';
import 'package:path/path.dart';

// questa classe gestisce tutto l'apparato dell'upload, si tratat di una classe globale che viene conservata in utility
class UploadManager {
  List<ProgressFile> _listProgressFile =
      []; // questa e' la lista degli upload che non solo ancora terminati
  Queue<ProgressFile> queueNotSent = Queue<ProgressFile>();

  // quando viene aggiunto un nuovo file da caricare, viene creato un progressFile per il corrispondente file che servira per ottenere tutte le informazioni sullo stato dell'upload
  ProgressFile uploadFile(
      File file, int idAppuntamento, String idChat, int typeUpload) {
    DateTime now = new DateTime.now();
    String nameUrl = Utility.getRandomString(100);

    ProgressFile progressFile = new ProgressFile(
        idAppuntamento, idChat, now, file, nameUrl, typeUpload);
    print("name-file-url: " + progressFile.getUrl());
    _listProgressFile.add(progressFile);

    if (_listProgressFile.length == 1) {
      _uploadFile(progressFile);
    } else {
      queueNotSent.add(progressFile);
    }

    return progressFile;
  }

  // lista dei progressFile attivi per una determinata chat
  List<ProgressFile> getListProgressFile(int idAppuntamento) {
    return _listProgressFile.where((element) {
      return element.idAppuntamento == idAppuntamento;
    }).toList();
  }

  void _uploadFile(ProgressFile progressFile) {
    var request = MultipartRequest();

    request.setUrl(EndPoint.getUrlKey(EndPoint.SEND_FILES) +
        "&datetime=${progressFile.dateTime.toString()}&id_appuntamento=${progressFile.idAppuntamento}&name=${progressFile.nameUrl}&id=${progressFile.idChat}");
    request.addFile("file", progressFile.file.path);

    Response response = request.send();

    // quando termina l'upload si puo' tranquillamente rimuovere dalla lista perche' non e' piu' in corso
    response.onError = () {
      _listProgressFile.remove(progressFile);
      if (queueNotSent.isNotEmpty) {
        _uploadFile(queueNotSent.removeFirst());
      }
    };

    // quando termina l'upload si puo' tranquillamente rimuovere dalla lista perche' non e' piu' in corso
    response.onComplete = (response) {
      _listProgressFile.remove(progressFile);
      if (queueNotSent.isNotEmpty) {
        _uploadFile(queueNotSent.removeFirst());
      }
    };

    // ogni volta che c'e' un aggiornamento invia l'informazione al ProgressFile, in questo modo se c'e' un listener, questo lo viene a sapere
    response.progress.listen((int progress) {
      progressFile.setProgress(progress);
    });
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
    print("extension-file: " + extension(file.path).substring(1));
    return extension(file.path).substring(1);
  }

  bool get isVideo {
    return getExtension() == "mp4";
  }
}
