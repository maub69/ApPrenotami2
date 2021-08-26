import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:better_player/better_player.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();

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

  // ricordati di usare questo link per la questione della cache: https://stackoverflow.com/questions/66488125/how-to-store-image-to-cachednetwrok-image-in-flutter
  // fare in modo che alla fine dell'upload venga rimosso il widget del caricamento
  // rendere cliccabile l'immagine al fine di farla vedere a schermo pieno
  // gestire gli altri caricamenti in attesa, magari mettendo una scritta tipo "in attesa di caricamento"
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          OpenFile.open(widget.progressFile.file.path);
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
                                      widget.progressFile.progress == 100
                                  ? 0
                                  : _progress),
                              semanticsLabel: 'Linear progress indicator'),
                          visible: widget.progressFile != null &&
                              widget.progressFile.progress != 100,
                        ),
                        Visibility(
                          child: Image(
                              image: AssetImage('images/file.png'), height: 45),
                          visible: widget.progressFile == null ||
                              widget.progressFile.progress == 100,
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

  String _getNameFileDownload() {

  }

 /* Future<String> _getPathToDownload() async {
    return getExternalStorageDirectories() .getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
}*/
}


/*

*/