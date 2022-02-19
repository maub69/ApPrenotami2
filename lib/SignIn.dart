import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/TextFieldCustomized.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'login.dart';
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
  TextEditingController email = TextEditingController();
  BuildContext contextGlobal;
  BuildContext _scaffoldContext;
  bool firstCheck = false;
  bool secondCheck = false;

  bool isSwitched = false;
  // String _textPolicy = "Policy";
  bool okPassword = false;
  bool okNome = false;
  bool okMail = false;
  bool isDisabilitato = true;
  bool _isObscure = true;
  bool _registrazioneOk = false;

  void _showMessage(String message) {
    //per funzionare necessita di utilizzare un context, sul quale poi appunto si applica la funzione showSnackBar
    //il problema pero' e' che non può essere utilizzato lo stesso context dello statefulwidget, percio' contextGlobal non puo essere usato
    //cio' significa che bisgona utilizzare un nuovo context, per fare cio' bisogna crearlo con l'oggetto Builder che si trova piu' sotto
    ScaffoldMessenger.of(_scaffoldContext).showSnackBar(new SnackBar(
      content: new Text(message),
      backgroundColor: Colors.orange,
    ));
  }

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
              child: ListView(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        EndPoint.getUrl(EndPoint.LOGO) + Utility.idApp + ".png",
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
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 20),
                          child: TextFieldCustomized(
                            controller: email,
                            iconPrefix: Icons.mail,
                            labelText: "Email",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 0),
                          child: TextFieldCustomized(
                            controller: passwordUtente,
                            iconPrefix: Icons.lock,
                            isPassword: true,
                            labelText: "Password",
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 18),
                          width: double.infinity,
                          child: GestureDetector(
                              onTap: () {
                                ChromeSafariBrowser().open(
                                    url: Uri.parse("https://www.google.com"));
                              },
                              child: Row(children: [
                                Text("Clicca qui",
                                    style: TextStyle( //TODO concludere la sezione registrazione, fare in modo che il bottone registrazione prenda vita e che vengano fatte le dovute validazioni
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900]),
                                    textAlign: TextAlign.left),
                                Text(" per leggere le condizioni di utilizzo",
                                    textAlign: TextAlign.left)
                              ])),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: firstCheck,
                              activeColor: Colors.green[900],
                              onChanged: (value) {
                                setState(() {
                                  firstCheck = value;
                                });
                              },
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Ho letto e accetto le condizioni',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: secondCheck,
                              activeColor: Colors.green[900],
                              onChanged: (value) {
                                setState(() {
                                  secondCheck = value;
                                });
                              },
                            ),
                            RichText(
                              text: TextSpan(
                                text:
                                    'Dichiaro di avere ${Utility.ageApp} o più',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        )
                        /*FormBuilderCheckboxGroup(
                              name: "check",
                              onChanged: onChangedField,
                              options: [
                                FormBuilderFieldOption(
                                    value: 'policy',
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Ho letto e accetto le condizioni di utilizzo dell\'applicazione',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    )),
                                FormBuilderFieldOption(
                                    value: 'age',
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Dichiaro di avere ${Utility.ageApp} o più',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            )*/
                        ,
                        //TODO aggingere i campi mancanti per la registrazione
                        //TODO fare in mdoo che il bottone registrati sia largo quanto l'applicazione
                        Container(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    textStyle: TextStyle(color: Colors.white)),
                                child: Text('Registrati'),
                                onPressed: (isDisabilitato
                                    ? null
                                    : onPressRegistrati)))
                      ])),
                ],
              )

/*ListView(
            children: [
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'REGISTRAZIONE',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Inserisci i dati per la registrazione',
                    style: TextStyle(fontSize: 16),
                  )),
              
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: GestureDetector(
                              child: Text(_textPolicy),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(
                                        builder: (BuildContext context) {
                                  return new WebViewWebPage();
                                }));
                              })),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          if (value) {
                            _textPolicy = "Policy (accettata)";
                          } else {
                            _textPolicy = "Policy";
                          }
                          isSwitched = value;
                          print(isSwitched);
                          setState(() {});
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      )
                    ]),
              ),
          )*/
              );
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
    //TODO sistemare la registrazione una volta che viene realizzato il backend
    if (true) {
      //_formKey.currentState.validate()
      http.post(
          Uri.parse(
              "https://prenotamionline.000webhostapp.com/registrazione.php"),
          body: {
            "username": nomeUtente.text,
            "email": email.text,
            "password": passwordUtente.text
          }).then((value) {
        print("Registrazione: ${value.body.toString()}");
        if (value.body == "0") {
          print("Username già esistente, digitare un diverso Username");
          _showMessage("Username già esistente, digitare un diverso Username");
          _registrazioneOk = false;
        } else if (value.body == "1") {
          print("Registrazione Utente eseguita correttamente");
          _showMessage("Registrazione Utente eseguita correttamente");
          _registrazioneOk = true;
        } else {
          print("Errore imprevisto, riprovare più tardi");
          _showMessage("Errore imprevisto, riprovare più tardi");
          _registrazioneOk = false;
        }

        //TODO se la risposta e' 0 allora da l'avviso di email occupata, altrimenti ti reindirizza al login
        //TODO intanto che aspetta la risposta il bottone registrati devi disattvarlo
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {
      print("validation failed");
    }
  }
}
