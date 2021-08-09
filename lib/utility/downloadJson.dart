import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';

/// classe che riceve un url e una funzione
/// invocando il metodo .start sull'oggetto
/// si esegue la funzione 'letturaTerminata' passata precedentemente,
/// sui dati ricevuti da http.get
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
    //da adesso non e' necessario inserire manualmente la key nella richiesta, ma viene fatto autmaticamente. Nei fatti viene aggiunto un nuovo attribbuto key con la chiave
    if (parametri == null) {
      parametri = {};
    }
    parametri["key"] = Utility.utente.id;
    Uri request = new Uri.https(
        EndPoint.HOST, "/" + url, parametri);

    print("richiesta: ${request.toString()}");

    http.get(Uri.parse(request.toString())).then((value) {
      // passandoli alla funzione 'letturaTerminata'
      if (letturaTerminata != null) {
        letturaTerminata(value);
      }
    });
  }
}
