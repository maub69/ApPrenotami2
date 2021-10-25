import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoAppBasso {
  static final double height = 40;

  static Widget getInfoContainer() {
    return Container(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Powered by "),
            GestureDetector(
                onTap: () => launch("https://www.google.com"),
                child: Text("ApPrenotami",
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
          Text("App personalizzate per la tua azienda")
        ],
      ),
    );
  }
}
