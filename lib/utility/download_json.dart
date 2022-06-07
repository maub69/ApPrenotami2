import 'package:http/http.dart' as http;
import 'cache_manager_url.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';

/// questa classe serve a gestire le richieste get per scaricare i json. Necessita dell'url e della funzione da avviare una volta finito di scaricare il json.
/// la funzione letturaTerminata viene eseguita una volta che il json viene scaricato
/// si tratta di una classe generica e' puo' essere usata in qualsiasi contesto serva scaricare un json e poi eseguire una funzione su di esso
    
class DownloadJson {
  // letturaTerminata serve a contenere una funzione
  // ha come tipo Function e come parametro vuole un oggetto di tipo http.Response
  Function(http.Response) letturaTerminata;
  //deve essere il nome del file che si intende richiamare, esempio "login.php"
  String url;
  //corrisponde al map con tutti i parametri get da passare con l'url
  Map<String, String> parametri;

  // costruttore che serve a popolare i parametri non obbligatori url e letturaterminata
  DownloadJson({this.url, this.parametri, this.letturaTerminata});

  // funzione chiamabile dopo aver instaziato l'oggetto tramite nomeoggetto.start
  // ritorneranno dei dati poi passati a letturaTerminata
  void start() {
    //da adesso non e' necessario inserire manualmente la key nella richiesta, ma viene fatto automaticamente. Nei fatti viene aggiunto un nuovo attributo key con la chiave
    if (parametri == null) {
      parametri = {};
    }
    parametri["key"] = Utility.utente.id;
    Uri request = new Uri.https(EndPoint.HOST, "/" + url, parametri);

    print("richiesta: ${request.toString()}");

    CacheManagerUrl.instance.get(request).then((value) {
      if (letturaTerminata != null) {
        letturaTerminata(value);
      }
    });
  }
}
