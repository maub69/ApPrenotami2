//import 'package:sqflite/sqflite.dart';
import 'package:mia_prima_app/utility/databaseHelper.dart';
import 'package:mia_prima_app/utility/utente.dart';

/// la classe Utility permette di utilizzare
/// dei dati tra le varie altre classi
class Utility {
  //fa riferimento all'id del amministratore del quale dovra' prendere il calendario, ora lo settiamo banalmente qui, ma poi si puo' pensare una logica migliroe per impostarlo
  static String idApp = "32";

  /// Utility.idUtente porta l'id dell'utente letto dal database
  /// e serve a riconoscerlo in modo univoco
  static String idUtente;

  /// Utility.Database
  static dynamic database;

  /// Utility.DatabaseHelper
  static DatabaseHelper databaseHelper;

  /// questa e la chiave di login con il quale l'utente si connette e manitne la connessione
  static Utente utente;
}
