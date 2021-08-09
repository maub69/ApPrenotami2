import 'package:mia_prima_app/utility/utility.dart';

class EndPoint {
  static final String HOST = "apprenotami.nlsitalia.com";

  static final String LOGIN = "test/login.php";

  static final String GET_CALENDARI = "test/getCalendari.php";

  static final String GET_CALENDARI_SETTIMANE =
      "test/getCalendariSettimane.php";

  static final String CREA_APPUNTAMENTO = "test/creaAppuntamento.php";

  static final String GET_APPUNTAMENTI = "test/getAppuntamenti.php";

  static final String DEL_PRENOTAZIONE = "test/eliminaPrenotazione.php";

  static final String GET_CHAT = "test/getChat.php";

  static final String MESSAGGIO_CHAT = "test/messaggioChat.php";

  static final String SET_CHAT_LETTA = "test/setChatLetta.php";

  static final String GET_CHAT_NON_LETTE = "test/getChatNonLette.php";

  static final String SEND_FILES = "test/sendFiles.php";

  static final String UPLOAD = "test/uploads/";

  static String getUrl(String url) {
    return "https://" + HOST + "/" + url;
  }

  static String getUrlKey(String url) {
    return "https://" + HOST + "/" + url + "?key=" + Utility.utente.id;
  }
}
