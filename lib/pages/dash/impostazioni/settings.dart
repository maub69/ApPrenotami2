import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/impostazioni/popup_notifica_settings.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifiche_manager.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'package:mia_prima_app/utility/utility.dart';
import '../../avvio/login.dart';
import '../../global/model.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SharedPreferences _pref;

  bool _switchToggle(String param, bool value) {
    setState(() {
      _pref.setBool(param, value);
    });
  }

  bool _getParam(String param) {
    if (_pref == null) {
      return true;
    }
    if (_pref.getBool(param) == null) {
      return true;
    }
    return _pref.getBool(param);
  }

  bool _getParamAppuntamentoActive() {
    if (_pref == null) {
      return NotificheManager.hasDefault;
    }
    if (_pref.getBool("notifica-appuntamento-exists") == null) {
      return NotificheManager.hasDefault;
    }
    return _pref.getBool("notifica-appuntamento-exists");
  }

  String convertValueNotifica() {
    if (!NotificheManager.hasDefault) {
      return "Mai";
    } else {
      switch (NotificheManager.minutesBefore) {
        case 30:
          return "30 minuti prima";
        case 60:
          return "1 ora prima";
        case 120:
          return "2 ore prima";
        case 360:
          return "6 ore prima";
        case 1440:
          return "1 giorno prima";
        case 2880:
          return "2 giorni prima";
        case 10080:
          return "1 settimana prima";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      _pref = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Model(
        body: SettingsList(
      sections: [
        SettingsSection(
          title: Text('Notifiche',
              style: TextStyle(color: Colors.black87, fontSize: 16)),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              onToggle: (value) {
                _switchToggle("notifica-attiva", value);
                RequestHttp.get(Uri.parse(
                    EndPoint.getUrlKey(EndPoint.SET_NOTIFICHE) +
                        "&enabled=" +
                        (value ? "1" : "0")));
              },
              initialValue: _getParam('notifica-attiva'),
              leading: Icon(Icons.notifications),
              title: Text('Attiva notifiche'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) =>
                  _switchToggle("notifica-attiva-suono", value),
              initialValue: _getParam('notifica-attiva-suono'),
              enabled: _getParam('notifica-attiva'),
              leading: Icon(Icons.volume_up),
              title: Text('Attiva suono'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) =>
                  _switchToggle("notifica-attiva-vibrazione", value),
              initialValue: _getParam('notifica-attiva-vibrazione'),
              enabled: _getParam('notifica-attiva'),
              leading: Icon(Icons.vibration),
              title: Text('Attiva vibrazione'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) =>
                  _switchToggle("notifica-attiva-bubble", value),
              initialValue: _getParam('notifica-attiva-bubble'),
              enabled: _getParam('notifica-attiva'),
              leading: Icon(Icons.bubble_chart),
              title: Text('Attiva bubble'),
              activeSwitchColor: Colors.green[900],
            ),
          ],
        ),
        SettingsSection(
            title: Text('Notifiche Prenotazioni',
                style: TextStyle(color: Colors.black87, fontSize: 16)),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: Icon(Icons.notification_add_sharp),
                  title: Text(
                      'Notifica default (${convertValueNotifica()})'),
                  value: Text('Notifica di default per gli appuntamenti'),
                  onPressed: (context) {
                    PopupNotificaSettings.showMenu(
                        context: context,
                        callToSet: (value) {
                          setState(() {
                            if (value == -1) {
                              NotificheManager.hasDefault = false;
                              Utility.preferences
                                  .setBool("notifica:has-default", false);
                            } else {
                              NotificheManager.hasDefault = true;
                              NotificheManager.minutesBefore = value;
                              Utility.preferences
                                  .setBool("notifica:has-default", true);
                              Utility.preferences
                                  .setInt("notifica:minutes-before", value);
                            }
                          });
                        });
                  })
              // TODO aggiungere un bottono sotto "Notifica di default" che se cliccato apre una finestra di scelta nel quale indicare quanto prima si vuole la notifica
            ]),
        SettingsSection(
          title: Text('Utente',
              style: TextStyle(color: Colors.black87, fontSize: 16)),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.logout),
              title: Text('Disconnetti'),
              value: Text('Disconnetti il tuo account'),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.only(top: 10.0),
                      title: Text("Ti vuoi disconnettere?"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      // content: Text("Fai tap su Si per uscire"),
                      content: Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(bottom: 2, top: 2, right: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5)),
                            color: Colors.green[900]),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 25, bottom: 10),
                                  child: Text("Annulla",
                                      style: TextStyle(
                                          fontSize: 19, color: Colors.white)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 15, bottom: 10),
                                  child: Text("Ok",
                                      style: TextStyle(
                                          fontSize: 19, color: Colors.white)),
                                ),
                              )
                            ]),
                      ),
                    );
                  },
                ).then((value) async {
                  if (value == null || value) {
                    print("sono qui 1");
                    final directory = await getApplicationDocumentsDirectory();
                    String path = directory.path;
                    File file = File('$path/id.txt');
                    file.delete();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Login(),
                        ),
                        ModalRoute.withName('/'));
                  }
                });
              },
            ),
          ],
        )
      ],
    ));
  }
}
