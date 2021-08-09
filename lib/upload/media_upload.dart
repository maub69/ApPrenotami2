import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_video_player/cached_video_player.dart';

class MediaUpload extends StatefulWidget {
  final ProgressFile progressFile;
  final bool isPhoto;

  const MediaUpload({Key key, this.progressFile, this.isPhoto})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MediaUploadState();
  }
}

class _MediaUploadState extends State<MediaUpload>
    with AutomaticKeepAliveClientMixin {
  double _progress;

  @override
  void initState() {
    super.initState();

    if (widget.progressFile.progress == 100) {
      _progress = 1;
    } else {
      _progress = 0;
    }

    widget.progressFile.setListener((progress) {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              Widget widgetShowed;

              if (widget.isPhoto) {
                widgetShowed = CachedNetworkImage(
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
                  imageUrl: widget.progressFile.getUrl(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                );
              } else {

                // TODO la libreria CachedVideoPlayerController sembra non funzionare, dovete provare a risolvere a cambiare libreria

                print("video-url: " + widget.progressFile.getUrl());
                // CachedVideoPlayerController controller =
                    // CachedVideoPlayerController.network(
                    //    "https://apprenotami.nlsitalia.com/test/uploads/Uz0Iu1AYqR375p2bHnsD2Ohb23zN1rA2nFsgYuA12hzm7ROkZ87dppJY3VFCTGX6FtrF1S99WvQEYZLmPg8e2JUauF9LtAxA2WYN.mp4");
                CachedVideoPlayerController controller = CachedVideoPlayerController.network(widget.progressFile.getUrl());
                controller.initialize().then((_) {
                  setState(() {});
                  controller.play();
                });

                widgetShowed =
                    controller.value != null && controller.value.initialized
                        ? AspectRatio(
                            child: CachedVideoPlayer(controller),
                            aspectRatio: controller.value.aspectRatio,
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
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
                Stack(alignment: Alignment.center, children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                          border: Border.all(
                            color: Colors.green[200],
                            width: 2,
                          )),
                      height: 200,
                      width: 300,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
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
                        imageUrl: (widget.isPhoto
                            ? widget.progressFile.getUrl()
                            : widget.progressFile.getUrl() + ".jpeg"),
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
                    visible: widget.progressFile.progress == 100,
                  ),
                  CircularProgressIndicator(
                      value:
                          (widget.progressFile.progress == 100 ? 0 : _progress),
                      semanticsLabel: 'Linear progress indicator'),
                ]),
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;
}


/*

*/