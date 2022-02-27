import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/TextFieldCustomized.dart';
import 'package:mia_prima_app/info_app_basso.dart';
import 'package:mia_prima_app/resetPassword.dart';
import 'package:mia_prima_app/utility/databaseHelper.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'SignIn.dart';
import 'dash.dart';
import 'package:path_provider/path_provider.dart';

/// classe per il login
/// se trova l'utente nel db prende il suo id
/// se remember e' cheked lo scrive in un file
/// rimandando poi alla pagina dash
/// se non lo trova avverte dell'errore e rimane nella pagina
///
class Login extends StatefulWidget {
  // Login() definisce il costruttore vuoto
  Login();

  @override
  // creazione stato per la classe Login
  State createState() => _LoginState();
}

/// classe che controlla se utente e password corrispondono e in caso affermativo
/// se spuntata la casella ricordami, memorizza i dati di login in un file
/// e rimanda alla pagina principale Dash (Dashboard)
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
      //con builder creao un nuovo context, nei fatti a livello grafico aver creato questo builder non porta a nessun tipo di modifica, tuttavia e' fondamentale per lo showSnackBar
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

  /// funzione che riceve i dati id e password
  /// e li salva nel percorso dell'applicazione
  /// all'interno del file id.txt
  void salvaLogin(String id, String email) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File file = File('$path/id.txt');
    file.writeAsString(id + ":" + email);
  }

  void onPressedLogin() {
    _isNotPressedLogin = false;
    setState(() {});
    /*http
                            .get("https://hansolo.ovh/ripetizioni/data_json")
                            .then((value) {
                          Map<String, dynamic> results = jsonDecode(value.body);
                          print(
                              "email: ${results["email"]} + password: ${results["password"]}");
                          if (results["email"] == nameController.text &&
                              results["password"] == passwordController.text) {
                            Alert(message: 'Login corretto').show();
                          } else {
                            print('Il login corretto è: ' +
                                results["email"] +
                                '\nil tuo login è: ' +
                                nameController.text +
                                '\nPassword corretta: ' +
                                results["password"] +
                                '\nPassword digitata: ' +
                                passwordController.text);
                            Alert(message: 'Login errato').show();
                          }
                        });*/
    /*
                        Utility.database.rawQuery(
                            "SELECT * FROM User WHERE username = ? and password = ?",
                            [
                              nameController.text,
                              passwordController.text
                            ]).then((value) {
                          if (value.isEmpty) {
                            Alert(message: 'Login errato').show();
                          } else {
                            if (_isChecked) {
                              salvaLogin(value[0]["id"]);
                            }
                            Utility.idUtente = value[0]["id"];
                            Utente utente = Utente(
                                email: value[0]["email"],
                                id: value[0]["id"],
                                username: value[0]["username"],
                                password: value[0]["password"]);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Dash(utente: utente)));
                          }
                          Utility.databaseHelper = DatabaseHelper();
                        });
                        */
    //
    http.post(Uri.parse(EndPoint.getUrl(EndPoint.LOGIN)), body: {
      "email": nameController.text,
      "password": passwordController.text
    }).then((value) {
      print("risposta: ${value.body}");
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
      Utility.databaseHelper = DatabaseHelper();
      _isNotPressedLogin = true;
      setState(() {});
    });
  }
}
