import 'package:flutter/material.dart';
import '../../../global/model.dart';

// TODO Cambiare colore bottone "filtra"
// La pagina che viene aperta quando si clicca sull'icona dei filtri dalla pagine della lista delle prenotazioni
class FiltraPage extends StatefulWidget {
  final List<TypeFiltro> filtri;
  final Function(List<TypeFiltro>) callback;

  const FiltraPage({Key key, this.filtri, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FiltraPageState();
  }
}

class _FiltraPageState extends State<FiltraPage> {
  Widget _body = Container();
  List<Widget> _listBody = [];

  List<TypeFiltro> _filtri = [
    TypeFiltro("PRENOTATO", 2),
    TypeFiltro("IN ATTESA DI CONFERMA", 1),
    TypeFiltro("DA CONFERMARE", 0),
    TypeFiltro("RIFIUTATO", -1),
    TypeFiltro("IN ATTESA DI CANCELLAZIONE", -2),
    TypeFiltro("CANCELLATO", -3),
    TypeFiltro("CONCLUSO", -4)
  ];

  @override
  Widget build(BuildContext context) {
    return Model(textAppBar: "Filtra", body: _body);
  }

  @override
  void initState() {
    super.initState();
    /// se in ingresso alla classe vengono passati dei filtri, questi vengono usati per settare il valore di quelli all'interno della pagina
    /// questo è importante per fare in modo che se ci sono dei filtri attivi, questi rimangono selezionati
    widget.filtri.forEach((element) {
      TypeFiltro typeFiltro =
          _filtri.where((e) => e.nameInt == element.nameInt).first;
      if (typeFiltro != null) {
        typeFiltro.value = element.value;
      }
    });

    /// per ogni filtro viene creato il widget della checkbox che lo rappresenta 
    _filtri.forEach((element) {
      _listBody.add(StatefulBuilder(
          builder: (context, _setState) => CheckboxListTile(
                title: Text(element.name),
                value: element.value,
                onChanged: (bool value) {
                  _setState(() {
                    element.value = value;
                  });
                },
              )));
    });

    setState(() {
      _body = Column(
        children: [
          Expanded(
              child: Container(
            child: ListView(
              children: _listBody,
            ),
          )),
          Container(
            height: 65,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 300),
                    /// Una volta che si preme il bottone viene chiamata la funzione callback che viene passata dalla classe lista appuntamenti
                    /// la quale poi filterà gli appuntamenti, gli passa alla funzione solo la lista dei filtri che non sono selezionati, cioè quelli che non su vuole visualizzare
                    child: ElevatedButton(
                      child: Text("Filtra",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: () {
                        widget.callback(_filtri
                            .where((element) => !element.value)
                            .toList());
                        Navigator.pop(context);
                      },
                    ))),
          )
        ],
      );
    });
  }
}

class TypeFiltro {
  final String name;
  final int nameInt;
  bool value = true;

  TypeFiltro(this.name, this.nameInt);
}
