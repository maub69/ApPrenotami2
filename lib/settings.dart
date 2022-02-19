import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
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
                http.get(Uri.parse(
                    EndPoint.getUrlKey(EndPoint.DEL_PRENOTAZIONE) +
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
