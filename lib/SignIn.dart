import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/TextFieldCustomized.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
// sutto il link per visualizzare una pagina web all'interno di flutter
//https://github.com/doomoolmori/flutter_inappbrowser

/// Classe per la registrazione dell'utente
/// Permette la registrazione inserendo nomeUtente, password e mail
/// e accettando la privacy policy (si può leggere da una apposita pagina)
/// Poi torna alla schermata di login

class SignIn extends StatefulWidget {
  SignIn();

  @override
  State createState() => _StateSignIn();
}

class _StateSignIn extends State<SignIn> {
  // creazione istanze di oggetti per la memorizzazione dei dati del form
  TextEditingController nomeUtente = TextEditingController();
  TextEditingController passwordUtente = TextEditingController();
  TextEditingController passwordUtente2 = TextEditingController();
  TextEditingController email = TextEditingController();
  BuildContext contextGlobal;
  BuildContext _scaffoldContext;
  bool firstCheck = false;
  bool secondCheck = false;
  bool _isDisabled = false;
  bool _userExists = false;
  bool isSwitched = false;
  bool okPassword = false;
  bool okNome = false;
  bool okMail = false;
  bool isDisabilitato = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    contextGlobal = context;
    return Scaffold(
        appBar: null,
        body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return Padding(
              padding: EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
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
                              top: 30, bottom: 15, left: 15, right: 15),
                          child: Column(children: <Widget>[
                            TextFieldCustomized(
                              controller: nomeUtente,
                              iconPrefix: Icons.people,
                              labelText: "Nome e Cognome",
                              validator: (String value) {
                                String name = value.trim();
                                if (name == "") {
                                  return "Nome e Cognome mancanti";
                                } else {
                                  Pattern pattern =
                                      r"^([ \u00c0-\u01ffa-zA-Z'\-])+$";
                                  RegExp regex = new RegExp(pattern);
                                  if (regex.hasMatch(name)) {
                                    return null;
                                  } else {
                                    return "Nome non valido";
                                  }
                                }
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 20),
                              child: TextFieldCustomized(
                                  controller: email,
                                  iconPrefix: Icons.mail,
                                  labelText: "Email",
                                  validator: (String value) {
                                    if (_userExists) {
                                      return "Email già registrata";
                                    }
                                    String email = value.trim();
                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = new RegExp(pattern);
                                    if (regex.hasMatch(email)) {
                                      return null;
                                    } else {
                                      return "Email errata";
                                    }
                                  }),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 0),
                              child: TextFieldCustomized(
                                  controller: passwordUtente,
                                  iconPrefix: Icons.lock,
                                  isPassword: true,
                                  labelText: "Password",
                                  validator: (String value) {
                                    Pattern pattern =
                                        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
                                    RegExp regex = new RegExp(pattern);
                                    if (regex.hasMatch(value)) {
                                      return null;
                                    } else {
                                      return "La password deve contenere:\n8 caratteri e un numero";
                                    }
                                  }),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 0),
                              child: TextFieldCustomized(
                                  controller: passwordUtente2,
                                  iconPrefix: Icons.lock,
                                  isPassword: true,
                                  labelText: "Ridigita la Password",
                                  validator: (String value) {
                                    if (value == passwordUtente.text) {
                                      return null;
                                    } else {
                                      return "Le password non corrispondono";
                                    }
                                  }),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              width: double.infinity,
                              child: GestureDetector(
                                  onTap: () {
                                    ChromeSafariBrowser().open(
                                        url: Uri.parse(
                                            "https://www.google.com"));
                                  },
                                  child: Row(children: [
                                    Text("Clicca qui",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[900]),
                                        textAlign: TextAlign.left),
                                    Text(
                                        " per leggere le condizioni di utilizzo",
                                        textAlign: TextAlign.left)
                                  ])),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30.0,
                                  width: 24.0,
                                  child: Checkbox(
                                    value: firstCheck,
                                    activeColor: Colors.green[900],
                                    onChanged: (value) {
                                      setState(() {
                                        firstCheck = value;
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => firstCheck = !firstCheck),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Ho letto e accetto le condizioni',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30.0,
                                  width: 24.0,
                                  child: Checkbox(
                                    value: secondCheck,
                                    activeColor: Colors.green[900],
                                    onChanged: (value) {
                                      setState(() {
                                        secondCheck = value;
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => secondCheck = !secondCheck),
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          'Dichiaro di avere ${Utility.ageApp} o più anni',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            Container(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.blue,
                                        textStyle:
                                            TextStyle(color: Colors.white)),
                                    child: Text('Registrati'),
                                    onPressed: (!_isDisabled &&
                                            firstCheck &&
                                            secondCheck
                                        ? onPressRegistrati
                                        : null)))
                          ])),
                    ],
                  )));
        }));
  }

//questa funzione viene avviata dal FormBuilderTextField quando viene settata nel campo onChanged
//se e' prensente anche solo un campo null o vuoto all'interno di uno dei campi, allora disabilito il bottone di registrazione
//cio' lo faccio innianzitutto con _formKey.currentState.save(), in questo modo salvo lo stato corrente dei valori che poi reperisco con _formKey.currentState.value
//la funzione thereIsNull ritorna true se uno dei valori all'interno di _formKey.currentState.value e' nullo, altrimenti ritorna false
  /*void onChangedField(value) {
    _formKey.currentState.save();
    //ho fatto questi due if un po' strani per evitare di fare tanti setState, avrei potuto verificare direttamente thereIsNull(_formKey.currentState.value), ma avrei fatto un sacco di setState
    if (!thereIsNull(_formKey.currentState.value) && isDisabilitato) {
      isDisabilitato = false;
      setState(() {});
    } else if (thereIsNull(_formKey.currentState.value) && !isDisabilitato) {
      isDisabilitato = true;
      setState(() {});
    }
  }*/

//la funzione thereIsNull ritorna true se uno dei valori all'interno di values e' nullo, altrimenti ritorna false
  bool thereIsNull(Map<String, dynamic> values) {
    bool thereIs = false;
    values.forEach((key, value) {
      if (value is bool) {
        if (!value) {
          thereIs = true;
        }
      } else if (value is List<String> && value.length != 2) {
        thereIs = true;
      } else if (value == null || (value is String && value.trim() == "")) {
        thereIs = true;
      }
    });
    return thereIs;
  }

  //qui effettivamente fa la validazione e se ci sono problemi aggiunge gli avvisi a livello grafico
  //non c'e' bisogno di fare il setState perche' se ne occupa il validate
  void onPressRegistrati() {
    print(nomeUtente.text);
    print(email.text);
    print(passwordUtente.text);
    print(passwordUtente2.text);
    _userExists = false;
    if (_formKey.currentState.validate()) {
      //_formKey.currentState.validate()
      setState(() {
        _isDisabled = true;
      });
      http.post(Uri.parse(EndPoint.getUrl(EndPoint.REGISTRAZIONE)), body: {
        "username": nomeUtente.text,
        "email": email.text,
        "password": passwordUtente.text
      }).then((value) {
        setState(() {
          _isDisabled = false;
        });
        print("Registrazione: ${value.body.toString()}");
        if (value.body == "0") {
          _userExists = true;
          _formKey.currentState.validate();
        } else if (value.body == "1") {
          print("Registrazione Utente eseguita correttamente");
          Utility.displaySnackBar(
              "Registrazione utente eseguita correttamente", _scaffoldContext);
          Navigator.pop(context);
        } else {
          print("Errore imprevisto, riprovare più tardi");
          Utility.displaySnackBar(
              "Errore imprevisto, riprovare più tardi", _scaffoldContext);
          // _registrazioneOk = false;
        }
      });
    } else {
      print("validation failed");
    }
  }
}
