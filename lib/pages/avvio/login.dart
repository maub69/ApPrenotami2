import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import '../global/text_field_customized.dart';
import '../global/info_app_basso.dart';
import 'resetPassword.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'SignIn.dart';
import '../dash/dash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login();

  @override
  State createState() => _LoginState();
}
class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isChecked = false;
  bool _isNotPressedLogin = true;
  BuildContext contextGlobal;
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    contextGlobal = context;
    return Scaffold(
      appBar: null,
      //con builder creo un nuovo context, nei fatti a livello grafico aver creato questo builder non porta a nessun tipo di modifica, tuttavia e' fondamentale per lo showSnackBar
      //si puo' vedere nella funzione _showMessage che viene utilizzato _scaffoldContext
      body: new Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          return Column(
            children: [
              Container(
                height: Utility.height - InfoAppBasso.height,
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    CachedNetworkImage(
                      imageUrl: EndPoint.getUrl(EndPoint.LOGO) +
                          Utility.idApp +
                          ".png",
                      height: 200,
                      fadeInDuration: Duration(seconds: 0),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 40),
                      child: TextFieldCustomized(
                        controller: nameController,
                        iconPrefix: Icons.mail,
                        isPassword: false,
                        labelText: "Email",
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFieldCustomized(
                        controller: passwordController,
                        iconPrefix: Icons.lock,
                        isPassword: true,
                        labelText: "Password",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 0, bottom: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ricordami"),
                            Checkbox(
                                value: _isChecked,
                                activeColor: Colors.green[900],
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                })
                          ]),
                    ),
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green[900],
                                textStyle: TextStyle(color: Colors.white)),
                            child: Text('Login'),
                            onPressed:
                                (_isNotPressedLogin ? onPressedLogin : null))),
                    Container(
                        margin: EdgeInsets.only(left: 12, top: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.login,
                                color: Colors.green[900],
                                size: 28.0,
                              ),
                            ),
                            Text('Per registrarti',
                                style: TextStyle(fontSize: 18)),
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle:
                                      TextStyle(color: Colors.green[900])),
                              child: Text(
                                'clicca qui',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.green[900]),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()),
                                );
                              },
                            )
                          ],
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.settings_backup_restore_outlined,
                              color: Colors.green[900],
                              size: 28.0,
                            ),
                          ),
                          Text('Password dimenticata?',
                              style: TextStyle(fontSize: 18)),
                          TextButton(
                            style: TextButton.styleFrom(
                                textStyle: TextStyle(color: Colors.green[900])),
                            child: Text(
                              'clicca qui',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.green[900]),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ResetPassword()),
                              );
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              InfoAppBasso.getInfoContainer()
            ],
          );
        },
      ),
    );
  }

  /// conserva all'interno del file id.txt l'id utente e l'email, per usarli per memorizzare il login
  void salvaLogin(String id, String email) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File file = File('$path/id.txt');
    file.writeAsString(id + ":" + email);
  }

  void onPressedLogin() {
    _isNotPressedLogin = false;
    setState(() {});
    RequestHttp.post(Uri.parse(EndPoint.getUrl(EndPoint.LOGIN)), body: {
      "username": nameController.text,
      "password": passwordController.text,
      "id_azienda": Utility.idApp
    }).then((value) {
      // print("risposta: ${value.body}");
      if (value.body == "-1") {
        Utility.displaySnackBar("Login errato", _scaffoldContext,
            type: 3, actionMessage: "CHIUDI");
      } else {
        if (_isChecked) {
          salvaLogin(value.body, nameController.text);
        }
        Utility.isLogged = true;
        Utility.idUtente = value.body;
        Utente utente = Utente(
            email: nameController.text,
            id: value.body,
            username: "",
            password: "");
        Utility.utente = utente;
        Navigator.pushReplacement(
            contextGlobal,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    Dash(idCalendario: Utility.idApp)));
      }
      _isNotPressedLogin = true;
      setState(() {});
    });
  }
}
