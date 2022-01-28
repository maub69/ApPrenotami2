import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Model(
        body: SettingsList(
      sections: [
        SettingsSection(
          title: Text('Notifiche', style: TextStyle(color: Colors.black87, fontSize: 16)),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: Icon(Icons.notifications),
              title: Text('Attiva notifiche'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              enabled: true,
              leading: Icon(Icons.volume_up),
              title: Text('Attiva suono'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              enabled: true,
              leading: Icon(Icons.vibration),
              title: Text('Attiva vibrazione'),
              activeSwitchColor: Colors.green[900],
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              enabled: true,
              leading: Icon(Icons.bubble_chart),
              title: Text('Attiva bubble'),
              activeSwitchColor: Colors.green[900],
            ),
          ],
        ),
        SettingsSection(
          title: Text('Utente', style: TextStyle(color: Colors.black87, fontSize: 16)),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.logout),
              title: Text('Disconnetti'),
              value: Text('Disconnetti il tuo account'),
              onPressed: (context) { },
            ),
          ],
        )
      ],
    ));
  }
}
