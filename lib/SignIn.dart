import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/utility.dart';
//import 'package:sqflite/sqflite.dart';
import 'dart:convert' show jsonDecode;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:passwordfield/passwordfield.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();
  // creazione istanze di oggetti per la memorizzazione dei dati del form
  TextEditingController nomeUtente = TextEditingController();
  TextEditingController passwordUtente = TextEditingController();
  TextEditingController email = TextEditingController();
  BuildContext contextGlobal;
  BuildContext _scaffoldContext;

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
    Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
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
        appBar: AppBar(
          centerTitle: true,
          title: Text('APPRENOTATI'),
        ),
        body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return Padding(
              padding: EdgeInsets.all(10),
              child: FormBuilder(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                          padding: EdgeInsets.all(15),
                          child: Column(children: <Widget>[
                            FormBuilderTextField(
                              name: 'nomeUtente',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nome e Cognome',
                              ),
                              onChanged: onChangedField,
                              // valueTransformer: (text) => num.tryParse(text),
                              //inserire qui tutti i controlli di validazione e verificare se esiste una validazione automatica per il match tra due form per la password
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context,
                                    errorText: 'Campo obbligatorio'),
                                FormBuilderValidators.minLength(context, 2,
                                    errorText:
                                        'Lunghezza minima di 2 caratteri')
                              ]),
                              keyboardType: TextInputType.text,
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: FormBuilderTextField(
                                name: 'passwordUtente',
                                obscureText: _isObscure,
                                decoration: InputDecoration(
                                  //aggiungendo questa sezione abbiamo aggiunto l'icona dell'occhio e in questo modo chiccandoci sopra la password diventa visibile
                                  suffixIcon: IconButton(
                                      icon: Icon(_isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      }),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.grey)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blue)),
                                  labelText: 'Password',
                                ),
                                onChanged: onChangedField,
                                // valueTransformer: (text) => num.tryParse(text),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context,
                                      errorText: 'Campo obbligatorio')
                                  //TODO aggiungere i controlli per la password, in particolare la validazione match con i regex, FormBuilderValidators.match()
                                ]),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            //TODO aggingere i campi mancanti per la registrazione
                            //TODO fare in mdoo che il bottone registrati sia largo quanto l'applicazione
                            Container(
                                height: 50,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: RaisedButton(
                                    textColor: Colors.white,
                                    color: Colors.blue,
                                    child: Text('Registrati'),
                                    //con questo if in riga abilito o meno in tasto con il classico approccio, cioe' aggiungendo o rimuovendo la funzione dal bottone
                                    onPressed: (isDisabilitato
                                        ? null
                                        : onPressRegistrati)))
                          ])),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: FormBuilderTextField(
                              name: 'email',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                              onChanged: onChangedField,
                              // valueTransformer: (text) => num.tryParse(text),
                              //inserire qui tutti i controlli di validazione e verificare se esiste una validazione automatica per il match tra due form per la password
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context,
                                    errorText: 'Campo obbligatorio'),
                                FormBuilderValidators.minLength(context, 2,
                                    errorText:
                                        'Lunghezza minima di 2 caratteri')
                              ]),
                              keyboardType: TextInputType.text,
                            ),),
                    ],
                  ))

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
  void onChangedField(value) {
    _formKey.currentState.save();
    //ho fatto questi due if un po' strani per evitare di fare tanti setState, avrei potuto verificare direttamente thereIsNull(_formKey.currentState.value), ma avrei fatto un sacco di setState
    if (!thereIsNull(_formKey.currentState.value) && isDisabilitato) {
      isDisabilitato = false;
      setState(() {});
    } else if (thereIsNull(_formKey.currentState.value) && !isDisabilitato) {
      isDisabilitato = true;
      setState(() {});
    }
  }

//la funzione thereIsNull ritorna true se uno dei valori all'interno di values e' nullo, altrimenti ritorna false
  bool thereIsNull(Map<String, dynamic> values) {
    bool thereIs = false;
    values.forEach((key, value) {
      if (value == null || value.trim() == "") {
        thereIs = true;
      }
    });
    return thereIs;
  }

  //qui effettivamente fa la validazione e se ci sono problemi aggiunge gli avvisi a livello grafico
  //non c'e' bisogno di fare il setState perche' se ne occupa il validate
  void onPressRegistrati() {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      print(
          "IF di Validazione, valori di formKey: ${_formKey.currentState.value}");
      http.post(Uri.parse("https://prenotamionline.000webhostapp.com/registrazione.php"),
          body: {
            "username": _formKey.currentState.value["nomeUtente"],
            "email": _formKey.currentState.value["email"],
            "password": _formKey.currentState.value["passwordUtente"]
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

/// classe che visualizza in una pagina la policy di gestione dati
/// presa da uno specifico URL
class WebViewWebPage extends StatelessWidget {
  WebViewWebPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Web View'),
        ),
        body: WebView(
          initialUrl:
              'https://docs.google.com/document/d/1TAqTE7MBzuIagISHHzjGxSHoY1z884LXR3iGIojz1sA/edit?usp=sharing',
        ));
  }
}
