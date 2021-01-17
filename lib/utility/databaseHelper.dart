import 'utility.dart';

/// Gestione dei dati 
/// 
class  DatabaseHelper {
  ///
  void insertIntoDati(
      {String idUtente, String titolo = "", String testo = "", int date}) {
    if (idUtente == null) {
      idUtente = Utility.idUtente;
    }

    Utility.database.rawInsert(
        'INSERT INTO Dati(id_utente, titolo, testo, data, fatto) VALUES(?, ?, ?, ?, 0)',
        [idUtente, titolo.trim(), testo.trim(), date]);
  }

  Future<List<Map<String, dynamic>>> getListaFrasi({int fatto = 0}) async {
    return await Utility.database.rawQuery(
        "SELECT * FROM Dati WHERE id_utente = ? AND fatto = ?",
        [Utility.idUtente, fatto]);
  }

  Future<void> deleteRowFrasi(int id) async {
    await Utility.database.delete("Dati where id = $id");
  }

  Future<void> archiviaFrase(int id) async {
    await Utility.database
        .rawUpdate("UPDATE Dati SET fatto = 1  WHERE name = ? AND id = $id", [
      Utility.idUtente
    ]);
  }
}
