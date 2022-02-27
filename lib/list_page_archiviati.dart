import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/visualizzaPrenotazioneFutura.dart';

class ListPage extends StatefulWidget {
  final String title;
  final List<dynamic> list;
  final Function getWidget;

  const ListPage({Key key, this.title, this.list, this.getWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> listNew = widget.list
        .where((element) => element["type"] == -5)
        .toList();
    print("-----> sono qui 10");
    return Model(
      textAppBar: widget.title,
      body: ListView.builder(
          itemCount: listNew.length + 1,
          itemBuilder: (context, i) {
            if (i == listNew.length) {
              return Container(height: 20);
            } else {
              return widget.getWidget(listNew[i], i, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            VisualizzaPrenotazioneFutura(
                                prenotazione: listNew[i]))).then((value) {
                  setState(() {});
                });
              });
            }
          }),
    );
  }
}
