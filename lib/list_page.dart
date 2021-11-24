import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';

class ListPage extends StatefulWidget {
  final String title;
  final List<dynamic> list;
  final Widget Function(dynamic, int) print;

  const ListPage({Key key, this.title, this.list, this.print})
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
    return Model(
      textAppBar: widget.title,
      body: ListView.builder(
          itemCount: widget.list.length + 1,
          itemBuilder: (context, i) {
            if (i == widget.list.length) {
              return Container(height: 20);
            } else {
              return widget.print(widget.list[i], i);
            }
          }),
    );
  }
}
