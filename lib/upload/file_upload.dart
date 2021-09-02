import 'dart:io' as io;
import 'dart:typed_data';

import 'package:alert/alert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:better_player/better_player.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUpload extends StatefulWidget {
  final ProgressFile progressFile;
  final String url;
  final DateTime datetime;
  final bool isAmministratore;
  final String name;

  const FileUpload(
      {Key key,
      this.progressFile,
      this.url,
      this.datetime,
      this.isAmministratore = false,
      this.name})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FileUploadState();
  }
}

class _FileUploadState extends State<FileUpload>
    with AutomaticKeepAliveClientMixin {
  double _progress;
  String _name;
  bool _isDownloaded = false;
  List<String> _extentionsMoveToTemp = [
    ".pdf",
    ".doc",
    ".docx",
    ".ppt",
    ".pptx",
    ".xls",
    ".xlsx"
  ];

  @override
  void initState() {
    super.initState();

    if (widget.progressFile == null) {
      _checkIfIsDownloaded().then((value) {
        setState(() {
          _isDownloaded = value;
        });
      });
    } else {
      _isDownloaded = true;
    }

    if (widget.progressFile == null) {
      _name = widget.name;
    } else {
      _name = basename(widget.progressFile.file.path);
    }

    if (widget.progressFile == null || widget.progressFile.progress == 100) {
      _progress = 1;
    } else {
      _progress = 0;
    }

    widget.progressFile?.setListener((progress) {
      setState(() {
        print("progress-file: $progress");
        _progress = progress.toDouble() / 100;
      });
    });
  }

  //TODO ricordadi di impedire un doppio download in contemporanea
  void _downloadFile() async {
    print("Scarica file");

    print(widget.url);

    DownloaderUtils downloaderUtils = DownloaderUtils(
      progressCallback: (current, total) {
        final progress = (current / total) * 100;
        print('download-file: Downloading: $progress');
      },
      file: io.File(_getPathFileDownloaded()),
      progress: ProgressImplementation(),
      onDone: () {
        print("download-file: ho fatto");
      },
      deleteOnCancel: true,
    );

    await Flowder.download(widget.url, downloaderUtils);
  }

  // ricordati di usare questo link per la questione della cache: https://stackoverflow.com/questions/66488125/how-to-store-image-to-cachednetwrok-image-in-flutter
  // fare in modo che alla fine dell'upload venga rimosso il widget del caricamento
  // rendere cliccabile l'immagine al fine di farla vedere a schermo pieno
  // gestire gli altri caricamenti in attesa, magari mettendo una scritta tipo "in attesa di caricamento"
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (widget.progressFile == null) {
            //redis
            if (_isDownloaded) {
              try {
                if (_extentionsMoveToTemp.contains(extension(widget.name))) {
                  io.Directory tempDir = await getTemporaryDirectory();
                  io.File tempFile = await io.File(_getPathFileDownloaded())
                      .copy('${tempDir.path}/${widget.name}');
                  OpenFile.open(tempFile.path);
                } else {
                  OpenFile.open(_getPathFileDownloaded());
                }

                io.Directory tempDir = await getTemporaryDirectory();
                io.File tempFile = await io.File(_getPathFileDownloaded())
                    .copy('${tempDir.path}/${widget.name}');
                OpenFile.open(tempFile.path);
              } catch (e) {
                print(e);
              }
            } else {
              await [
                Permission.storage,
                Permission.manageExternalStorage
              ].request().then((value) {
                if (value[Permission.storage].isGranted && value[Permission.manageExternalStorage].isGranted) {
                  _downloadFile();
                } else {
                  Alert(
                        message:
                            'In assenza di permessi non si può procedere con il download',
                        shortDuration: false)
                    .show();
                }
              });
            }
          } else {
            OpenFile.open(widget.progressFile.file.path);
            print("message-open-upload: ${widget.progressFile.file.path}");
          }
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Colors.green[200],
                        width: 2,
                      )),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text("20/2/2021 9:30", style: TextStyle(fontSize: 12)),
                  width: 300,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Colors.green[200],
                        width: 2,
                      )),
                  padding:
                      EdgeInsets.only(top: 0, bottom: 20, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 220,
                        child: Text(_name),
                      ),
                      Stack(alignment: Alignment.center, children: <Widget>[
                        Visibility(
                          child: CircularProgressIndicator(
                              value: (widget.progressFile == null ||
                                      widget.progressFile.progress == 100)
                                  ? 0
                                  : _progress,
                              semanticsLabel: 'Linear progress indicator'),
                          visible: _isDownloaded &&
                              widget.progressFile != null &&
                              widget.progressFile.progress != 100,
                        ),
                        Visibility(
                          child: Image(
                              image: AssetImage('images/file.png'), height: 45),
                          visible: _isDownloaded &&
                              (widget.progressFile == null ||
                                  widget.progressFile.progress == 100),
                        ),
                        Visibility(
                          child: Image(
                              image: AssetImage('images/download.png'),
                              height: 35),
                          visible: !_isDownloaded &&
                              (widget.progressFile == null ||
                                  widget.progressFile.progress == 100),
                        ),
                      ])
                    ],
                  ),
                  width: 300,
                )
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;

  Future<bool> _checkIfIsDownloaded() async {
    print("percorso-file: ${_getPathFileDownloaded()}");
    if (await Permission.storage.isGranted) {
      io.File file = new io.File(_getPathFileDownloaded());
      return await file.exists();
    } else {
      return false;
    }
  }

  String _getPathFileDownloaded() {
    return Utility.pathDownload +
        "/" +
        Utility.getDateInCorrectFormat(widget.datetime) +
        "_" +
        widget.name;
  }

  Future<String> toRemove() async {
    /*await [
        Permission.storage,
      ].request().then((value) {
        if (value[Permission.storage].isGranted) {
          print("permesso: attivo");
        } else {
          print("permesso: non attivo");
        }
      });*/

    /*if (await Permission.storage.request().isGranted) {
        print("permesso-1: attivo");
      } else {
        print("permesso-1: non attivo");
      }*/

    if (await Permission.storage.isGranted) {
      print("permesso-2: attivo");
    } else {
      print("permesso-2: non attivo");
    }
  }
}


/*

*/