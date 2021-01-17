import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
// import 'package:mia_prima_app/utility/databaseHelper.dart';
import 'package:mia_prima_app/utility/utility.dart';

class VisualizzaFrasi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateVisualizzaFrasi();
  }
}

class _StateVisualizzaFrasi extends State<VisualizzaFrasi> {
  List<Widget> _widgetsList = [];

  @override
  void initState() {
    super.initState();
    aggiorna().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Model(
        body: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: _widgetsList.length,
            itemBuilder: (BuildContext context, int index) {
              return _widgetsList[index];
            }));
  }

  Future<void> aggiorna() async {
    _widgetsList = [];
    List<Map<String, dynamic>> lista =
        await Utility.databaseHelper.getListaFrasi();
    lista.forEach((element) {
      _widgetsList.add(_createTape(element));
    });
  }

  Widget _createTape(Map<String, dynamic> element) {
    int id = element["id"];
    int dataUnix = element["data"];
    DateTime data = DateTime.fromMillisecondsSinceEpoch(dataUnix);

    /*return Card(
      child: ListTile(
        title: Flexible(child: Text("${element["titolo"]} ${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute}.${data.second}")),
        subtitle: Text(element["testo"]),
        leading: SizedBox(
          height: 10,
          width: 10,
          child: IconButton(
            icon: Icon(Icons.check),
            color: Colors.blue,
            tooltip: 'Archivia',
            onPressed: () {}),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              tooltip: 'Elimina',
              onPressed: () {
                showAlert(context, id);
              }),
        ]),
        isThreeLine: true,
      ),
    );*/
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.check),
                color: Colors.blue,
                tooltip: 'Archivia',
                onPressed: () {
                  Utility.databaseHelper.archiviaFrase(id).then((value) {
                    aggiorna().then((value) => setState(() {}));
                  });
                }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${element["titolo"]}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                    "${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute}.${data.second}",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(element["testo"])
              ],
            ),
            Expanded(child: Text("")),
            IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Elimina',
                onPressed: () {
                  showAlert(context, id);
                })
          ],
        ),
      ),
    );
  }

  void showAlert(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Elimina frase'),
          content: Text("Sei sicuro di volerlo eliminare definitivamente?"),
          actions: <Widget>[
            FlatButton(
              child: Text("SI"),
              onPressed: () {
                Utility.databaseHelper.deleteRowFrasi(id).then((value) {
                  aggiorna().then((value) => setState(() {}));
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
