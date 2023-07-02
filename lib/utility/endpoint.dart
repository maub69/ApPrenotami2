import 'package:mia_prima_app/utility/utility.dart';
class EndPoint {
  static final String HOST = "192.168.1.12:5000";

  // verra' utilizzata la registrazione proposta la laravel, percio' nel momento nel quale capiremo come utilizzarla imposteremo i parametri al fine di farlo funzionare
  static final String REGISTRAZIONE = "register";

  // verra' utilizzato il login proposto la laravel, percio' nel momento nel quale capiremo come utilizzarlo imposteremo i parametri al fine di farlo funzionare
  static final String LOGIN = "login";

  // id azienda di cui avere le informazioni per poi accedere anche ai calendari
  // in questo endpoint si potrebbero aggiungere info come numero di telefono / email / settaggio personalizzato dei colori
  static final String GET_INFO_AZIENDA = "test/getCalendari.php";
  
  // fornisce la lista ti tutti i calendari che gestisce l'azienda e per ogni calendario fornisce le disponibilita'
  static final String GET_CALENDARI_AZIENDA = "getCalendariSettimane";

  // cancella un appuntamento
  static final String CANCELLA_APPUNTAMENTO = "test/appuntamento.php";

  // archivia un appuntamento
  static final String ARCHIVIA_APPUNTAMENTO = "test/archiviaAppuntamento.php";

  // invia un appuntamento
  static final String INVIO_RICHIESTA_APPUNTAMENTO = "creaAppuntamento";

  // fornisce la lista delle prenotazioni, che fondamentalmente e' quella presente nell'interfaccia "Lista appuntamenti"
  static final String GET_LISTA_PRENOTAZIONI = "getAppuntamenti";

 // permette di inviare una richiesta per cancellare una prenotazione, ma anche per archiviarla, questo si decide in base al campo tipo nella richiesta
  static final String CANCELLA_PRENOTAZIONE = "test/eliminaPrenotazione.php";

  // fornisce tutta la chat per un deteminato appuntamento
  static final String GET_CHAT = "test/getChat.php";

  // endpoint usato per inviare da parte dell'app i messaggi al server, sono presenti diversi tipi di messaggi inviabili come specificato su postman
  static final String MESSAGGIO_CHAT = "test/messaggioChat.php";

 // serve per specificare l'id del messaggio che e' segnato come letto in una chat
  static final String SET_CHAT_LETTA = "test/setChatLetta.php";

  // ritorna la lista degli id delle chat non lette
  static final String GET_CHAT_NON_LETTE = "getChatNonLette";

  // permette di comunicare al server se intendi ricevere notifiche di qualsiasi genere o meno, questo lo si setta tramite il parametro enabled
  static final String SET_NOTIFICHE = "test/setNotifiche.php";

  // endpoint usato per inviare il file, stare molto attenti a che significano i parametri, il loro significato e specificato su postman
  static final String SEND_FILES = "test/sendFiles.php";

  // endpoint usato per inviare la richiesta di reset password per una specifica email
  static final String RESET_PASSWORD = "test/resetPassword.php";

// questo percorso specifica in quale location cercare i file che precedentemente sono stati caricati, quindi e la cartella dei send files
// https://github.com/google/leveldb --> usare per salvare i file
  static final String UPLOAD = "test/uploads/";

// dove si troveranno i loghi di tutte le aziende
  static final String LOGO = "front/logos/";

  static String getUrl(String url) {
    return "http://" + HOST + "/" + url;
  }

  // fuznione che ti torna l'url contenente anche la chiave di autenticazione, molto probabilmente questa funzione andra' aggiornata in quanto useremo il login di laravel
  static String getUrlKey(String url) {
    return "http://" + HOST + "/" + url + "?key=" + Utility.utente.id;
  }
}
