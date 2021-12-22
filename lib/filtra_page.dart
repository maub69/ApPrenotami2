import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/utility.dart';

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
    widget.filtri.forEach((element) {
      TypeFiltro typeFiltro = _filtri.where((e) => e.nameInt == element.nameInt).first;
      if (typeFiltro != null) {
        typeFiltro.value = element.value;
      }
    });

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
