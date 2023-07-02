import 'package:flutter/material.dart';
import 'package:mia_prima_app/utility/pop_bottom_menu.dart';

/// rappresenta il popup per aggiungere una notifica ad un appuntamento
class PopupAddNotifica {
  static void showMenu({@required BuildContext context, Function callToSet}) {
    List<ItemPopBottomMenu> items = [];

    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(30);
        Navigator.pop(context);
      },
      label: "30 minuti prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(60);
        Navigator.pop(context);
      },
      label: "1 ora prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(120);
        Navigator.pop(context);
      },
      label: "2 ore prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(360);
        Navigator.pop(context);
      },
      label: "6 ore prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(1440);
        Navigator.pop(context);
      },
      label: "1 giorno prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(2880);
        Navigator.pop(context);
      },
      label: "2 giorni prima",
    ));
    items.add(ItemPopBottomMenu(
      onPressed: () {
        callToSet(10080);
        Navigator.pop(context);
      },
      label: "1 settimana prima",
    ));

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return PopBottomMenu(
          title: TitlePopBottomMenu(
            label: "Opzioni",
          ),
          items: items,
        );
      },
    );
  }
}
