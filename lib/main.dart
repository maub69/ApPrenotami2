import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert' show jsonDecode;
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/login.dart';
import 'package:mia_prima_app/sceltaCalendario.dart';
import 'package:mia_prima_app/utility/databaseHelper.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'SignIn.dart';
import 'dash.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  // la funzione di init main() contiene la funzione di bindig runApp()
  // alla quale viene passata la classe MaterialApp() e quindi il suo costruttore
  // la quale ritorna l'indirizzo dell'oggetto che viene istanziato dal framework
  // e ha come parametro di home la classe MyApp()

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  // sovrascritta createState() passandogli il costruttore della classe _MyAppState
  // che crea una nuova istanza
  State createState() => _MyAppState();
  // => l'elemento che rappresenta il corpo della funzione(l'istruzione tra graffe)
  // Posso ritornare State perche _MyAppState eredita da State (riga sotto)
  // Se sostituisco il tipo di ritorno State con _MyAppState andrebbe bene lo stesso
}

class _MyAppState extends State<MyApp> {
  // la classe tra < > sostituisce "T" un template a cui si passa
  // la classe che deve essere utilizzata come tipo

  /// nella variabile '_body' si inserisce il Widget Text per adesso vuoto
  /// che permettera' poi di inserire le istruzioni
  /// che comporranno la schermata da visualizzare
  Widget _body = Text("");

  /// la variabile 'file' conterra' il file dove è scritto l'ID di login
  File file;

  /// la funzione asincrona manageDatabase()
  /// crea il database di tipo sqlite se non esiste
  void manageDatabase() async {
    // Get a location using getDatabasesPath
    //var databasesPath = await getDatabasesPath();
    //print("scrivi: $databasesPath");

    /// la variabile Stringa 'path' contiene percorso e nome del file del db
    //String path = databasesPath + "/" + 'dbapp.db';

    /// Apertura database e si mette a disposizione in Utility.database
    /*Utility.database = await openDatabase(path, version: 1,
        //funzione anonima asincrona di nome OnCreate che riceve due parametri
        // si utilizza anonima quando si usa una sola volta
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE User (id INTEGER PRIMARY KEY autoincrement, username TEXT, password TEXT, email TEXT, tipoUtente TEXT, ultimoLogin TEXT)');
      await db.execute(
          'CREATE TABLE Dati (id INTEGER PRIMARY KEY autoincrement, id_utente INTEGER, titolo TEXT, testo TEXT, data INTEGER, fatto INTEGER)');
    });*/
    Utility.databaseHelper = DatabaseHelper();
  }

  /// legge i dati presenti dal file id.txt
  /// creato nella directory di lavoro dell'applicazione
  /// e li ritorna memorizzandoli nell'oggetto Utility.idUtente
  Future<String> _getDataLogin() async {
    // si memorizza in directory l'oggetto in cui è contenuto il path interno
    // che userà questa applicazione per memorizzare i file
    final directory = await getApplicationDocumentsDirectory();
    try {
      String path = directory.path;
      // id.txt è il nome del file utilizzato
      // da metterre in un file di configurazione?
      this.file = File('$path/id.txt');
      // si legge il file e si memorizza in Utility.idUtente
      Utility.idUtente = await file.readAsString();
      // ritorna la riga letta o in caso di errore la stringa "-1"
      return Utility.idUtente;
    } catch (e) {
      return "-1";
    }
  }

  /// funzione per cancellare il file id.txt
  ///  dove sono memorizzati i dati di login dell'utente
  void delDataLogin() async {
    //this.file è facoltativo scriverla se esiste una sola var con questo nome
    this.file.delete();
  }

  @override
  void initState() {
    super.initState();
    manageDatabase();
  }

  @override
  Widget build(BuildContext context) {
    // la funzione _getDataLogin() restituisce un valore 'id'
    // quando arriva l 'id' (attende il then) che poi viene valutata dalla funzione anonima
    _getDataLogin().then((id) {
      // se id non esiste
      if (id == "-1") {
        setState(() {
          /// Reindirizzazione dell'utente alla pagina di login
          _body = Login();
        });
        // se id è nel db
      } else {
        // chiama la funzione che recupera i dATI UTENTE TRAMITE ID e li passa alla classe Dash
        _goOnDash(id);
      }
    });

    return _body;
  }

  // recupera i dATI UTENTE TRAMITE ID e li passa alla classe Dash
  void _goOnDash(String id) async {
    /*List<Map> list = await Utility.database
        .rawQuery("SELECT * FROM User WHERE id = ?", [id]);
    Utente utente = Utente(
        email: list[0]["email"],
        id: list[0]["id"],
        username: list[0]["username"],
        password: list[0]["password"]);*/

    //TODO RINOMINARE id in key, questo perche' non e' piu' l'id dell'utente, ma la chiave che usa quest'ultimo per collegarsi
    List<String> idEmail = id.split(":");
    Utente utente =
        Utente(email: idEmail[1], id: idEmail[0], username: "", password: "");

    Utility.utente = utente;
    setState(() {
      _body = SceltaCalendario();
    });
    /*setState(() {
      _body = Dash(utente: utente);
    });*/
  }
}
