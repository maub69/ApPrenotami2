import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as nt;
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart'
    as ni;
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifiche_manager.dart';
import 'pages/avvio/login.dart';
import 'utility/notification_sender.dart';
import 'package:mia_prima_app/utility/messages_manager.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/dash/dash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {}
  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData(
      primaryColor: Colors.green[900],
    ),
  ));
}

/// Campi utilizzati per aprire automaticamente la pagina dell'appuntamento quando viene cliccata una notifica
/// e l'applicazione e chiusa o è in pausa, viene valorizzata da notification_sender e poi viene usata dalla dash per avviare
/// automaticamente la pagina
String idCalendario = "-1";
String idAppuntamento = "-1";
/// classe istanziata per essere usata successivamente solo dalla classe notification sender
/// viene messa qui per essere resa globale e sempre disponibile
nt.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class MyApp extends StatefulWidget {
  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Widget _body = Text("");

  /// la variabile 'file' conterra' il file dove è scritto l'ID di login
  File file;

  /// legge i dati presenti dal file id.txt
  /// creato nella directory di lavoro dell'applicazione
  /// e li ritorna memorizzandoli nell'oggetto Utility.idUtente
  Future<String> _getDataLogin() async {
    /// si memorizza in directory l'oggetto in cui è contenuto il path interno
    /// che userà questa applicazione per memorizzare i file
    final directory = await getApplicationDocumentsDirectory();
    try {
      // TODO APP ricordarsi che in fase di compilazione dell'app per un cliente il file cliente.txt deve contenere l'id univoco del cliente
      /// il campo idApp è molto importante, infatti specifica l'id del cliente che ha acquista l'app come servizio
      /// all'interno del file è presente solo l'id, che verrà usato poi in tutta l'app per riconoscere il cliente
      Utility.idApp = await rootBundle.loadString('files/cliente.txt');
      String path = directory.path;
      this.file = File('$path/id.txt');
      // si legge il file e si memorizza in Utility.idUtente
      Utility.idUtente = await file.readAsString();
      // ritorna la riga letta o in caso di errore la stringa "-1"
      return Utility.idUtente;
    } catch (e) {
      return "-1";
    }
  }

  /// permette di scaricare nuovamente le chat non lette appena l'app ritorna in funzione dopo che viene messa in background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Utility.isLogged && state == AppLifecycleState.resumed) {
      MessagesManager.downloadChatNonLette();
    }
  }

  @override
  void initState() {
    super.initState();

    /// utilizzata per impostare la libreria che gestisce il database interno delle preferenze
    /// all'avvio dell'app vengono impostati i valori di default relativi alla notifica in automatico che viene inviata per ricordarti di un appuntamento
    SharedPreferences.getInstance().then((value) {
      Utility.preferences = value;
      if (value.containsKey("notifica:has-default")) {
        NotificheManager.hasDefault = value.getBool("notifica:has-default");
        NotificheManager.minutesBefore = value.getInt("notifica:minutes-before");
      }
    });

    /// settaggio iniziale del canale delle notifiche per dove passano le notifiche per ricordarti dell'appuntamento
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'scheduler_prenotazioni_high',
            channelName: 'Avvisi prenotazioni scheduler',
            channelDescription: 'Avvisi delle prenotazioni scheduler',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
          ),
        ]);

    /// Vengono settati dei listener che nel corso di tutto l'utilizzo dell'applicazione monitorano lo stato della connessione
    /// e nel caso ci siano dei cambiamenti settano la variabile hasInternet che verrà poi utilizzata nell'app
    /// Il primo blocco controlla istantaneamente qual'è la connettività, mentre il blocco dopo avvia il listener
    /// per i futuri cambi di connettività
    Connectivity().checkConnectivity().then((value) {
      Utility.hasInternet = value != ConnectivityResult.none;
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      Utility.hasInternet = result != ConnectivityResult.none;
    });

    /// vengano settati i campi per conoscere la folder dei file temporanei e permanenti
    /// lo facciamo fin dall'avvio e non successivamente perché essendo una chiamata asincrona poi darebbe problemi in seguito 
    getTemporaryDirectory()
        .then((value) => Utility.pathTmpDownload = value.path);
    getApplicationSupportDirectory()
        .then((value) => Utility.pathDownload = value.path);

    /// aggiunge la classe agli oggetti monitorati dal sistema, in questo modo le varie funzioni che necessitano di informazioni di sistema possono funzionare
    WidgetsBinding.instance.addObserver(this);

    /// verifica se l'utente è autenticato o meno e apre la pagina di login o la dash
    _getDataLogin().then((id) {
      // se id non esiste
      if (id == "-1") {
        setState(() {
          /// Reindirizzazione dell'utente alla pagina di login
          _body = Login();
        });
        // se id è nel db
      } else {
        Utility.isLogged = true;
        // chiama la funzione che recupera i dATI UTENTE TRAMITE ID e li passa alla classe Dash
        _goOnDash(id);
      }
    });

    SharedPreferences.getInstance().then((value) {
      FirebaseMessaging.instance
          .getToken()
          .then((token) => print("token-app: $token"));
      FlutterNotificationChannel.registerNotificationChannel(
        description: 'Qui ricevi le notifiche per gli appuntamenti',
        id: 'apprenotami.appuntamenti',
        importance: ni.NotificationImportance.IMPORTANCE_HIGH,
        name: 'Appuntamenti',
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
        allowBubbles: value.getBool("notifica-attiva-bubble") ?? true,
        enableVibration: value.getBool("notifica-attiva-vibrazione") ?? true,
        enableSound: value.getBool("notifica-attiva-suono") ?? true,
        showBadge: true,
      );

      getMessage();
    });
  }

  void getMessage() {
    NotificationSender notificationSender = NotificationSender();
    notificationSender.configureFirebaseNotificationOnStart();
  }

  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    // la funzione _getDataLogin() restituisce un valore 'id'
    // quando arriva l 'id' (attende il then) che poi viene valutata dalla funzione anonima
    Utility.width = MediaQuery.of(context).size.width;
    Utility.height = MediaQuery.of(context).size.height;
    return _body;
  }

  // recupera i DATI UTENTE TRAMITE ID e li passa alla classe Dash
  void _goOnDash(String key) async {
    List<String> idEmail = key.split(":");
    Utente utente = Utente(email: idEmail[1], id: idEmail[0], username: "", password: "");
    Utility.utente = utente;

    MessagesManager.downloadChatNonLette();
    setState(() {
      _body = Dash(idCalendario: Utility.idApp);
    });
  }
}
