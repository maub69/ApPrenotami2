import 'dart:typed_data';

import 'package:alert/alert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/FileSystemNew.dart';
import 'package:mia_prima_app/chat/risposte/popup_menu_chat.dart';
import 'package:mia_prima_app/chatpage.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:better_player/better_player.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:open_file/open_file.dart';

class MediaUpload extends StatefulWidget {
  final ProgressFile progressFile;
  final bool isPhoto;
  final String url;
  final DateTime datetime;
  final bool isAmministratore;
  final String idAppuntamento;
  final String idChat;

  const MediaUpload(
      {Key key,
      this.progressFile,
      this.isPhoto,
      this.url,
      this.datetime,
      this.isAmministratore = false,
      this.idAppuntamento,
      this.idChat})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MediaUploadState();
  }
}

class _MediaUploadState extends State<MediaUpload>
    with AutomaticKeepAliveClientMixin {
  double _progress;
  String _url;
  DateTime _datetime;
  CacheManager _cacheManager;
  bool _isAlreadyShown;

  @override
  void initState() {
    super.initState();
    _cacheManager = Utility.getCacheManager(widget.idAppuntamento);

    if (widget.progressFile == null) {
      _url = widget.url;
      _datetime = widget.datetime;
    } else {
      _url = widget.progressFile.getUrl();
      _datetime = widget.progressFile.dateTime;
    }
    if (!widget.isPhoto) {
      print("url_media: $_url");
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
        onLongPress: () {
          PopupMenuChat.showMenu(
            context: Model.getContext(),
            isAmministratore: !widget.isAmministratore,
            isChat: false,
            idChat: widget.idChat,
            widget: widget
          );
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              Widget widgetShowed;
              if (widget.isPhoto) {
                widgetShowed = CachedNetworkImage(
                    cacheManager: _cacheManager,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(6),
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    imageUrl: _url,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    placeholder: (context, url) =>
                        Container(child: CircularProgressIndicator()));
              } else {
                _isAlreadyShown = false;
                BetterPlayerController betterPlayerController;
                BetterPlayerDataSource betterPlayerDataSource;
                if (widget.progressFile == null) {
                  betterPlayerDataSource = BetterPlayerDataSource(
                      BetterPlayerDataSourceType.network, _url,
                      cacheConfiguration: BetterPlayerCacheConfiguration(
                          useCache: true,
                          maxCacheSize: 500 * 1024 * 1024,
                          maxCacheFileSize: 100 * 1024 * 1024,
                          pathExtra: widget.idAppuntamento));
                } else {
                  betterPlayerDataSource = BetterPlayerDataSource(
                      BetterPlayerDataSourceType.file,
                      widget.progressFile.file.path.toString());
                }

                betterPlayerController = BetterPlayerController(
                    BetterPlayerConfiguration(),
                    betterPlayerDataSource: betterPlayerDataSource);

                betterPlayerController.addEventsListener((event) {
                  if (!_isAlreadyShown && event.betterPlayerEventType == BetterPlayerEventType.exception) {
                    if (event.parameters["exception"].toString().toLowerCase().contains("source error")) {
                      _isAlreadyShown = true;
                      Alert(message: 'Internet assente, il video non è in cache e perciò non può essere visualizzato', shortDuration: false).show();
                    }
                  }
                });

                widgetShowed = BetterPlayer(
                  controller: betterPlayerController,
                );

                /*VideoPlayerController controllerVideo;
                controllerVideo =
                    VideoPlayerController.network(widget.progressFile.getUrl())
                      ..initialize().then((_) {
                        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                        setState(() {});
                        controllerVideo.play();
                      });
                widgetShowed = VideoPlayer(controllerVideo);*/
              }

              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: widgetShowed,
                ),
              );
            }),
          );
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            alignment: widget.isAmministratore
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: widget.isAmministratore
                          ? Colors.white
                          : Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: widget.isAmministratore
                            ? Colors.white
                            : Colors.green[200],
                        width: 2,
                      )),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(_getStringFromDateTime(_datetime),
                      style: TextStyle(fontSize: 12)),
                  width: 300,
                ),
                Stack(alignment: Alignment.center, children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                          border: Border.all(
                            color: widget.isAmministratore
                                ? Colors.white
                                : Colors.green[200],
                            width: 2,
                          )),
                      height: 200,
                      width: 300,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        cacheManager: _cacheManager,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(6),
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        imageUrl: (widget.isPhoto ? _url : _url + ".jpeg"),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                  Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(
                              (255 * (1 - (_progress < 0.2 ? 0.2 : _progress)))
                                  .toInt(),
                              255,
                              255,
                              255),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(6),
                          ))),
                  Visibility(
                    child: Image(image: AssetImage('images/play-button.png')),
                    visible: (widget.progressFile == null ||
                            widget.progressFile.progress == 100) &&
                        !widget.isPhoto,
                  ),
                  CircularProgressIndicator(
                      value: (widget.progressFile == null ||
                              widget.progressFile.progress == 100
                          ? 0
                          : _progress),
                      semanticsLabel: 'Linear progress indicator'),
                ]),
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;

  String _getStringFromDateTime(DateTime datetime) {
    return "${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${(datetime.minute >= 10) ? datetime.minute : "0" + datetime.minute.toString()}";
  }
}


/*

*/