import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app/models/transaction.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _transactionsKey = 'transactions';

  DatabaseHelper._init();

  Future<List<model.Transaction>> _readAll() async {
    final res = await SharedPreferences.getInstance();
    final jsonList = res.getStringList(_transactionsKey) ?? [];
    return jsonList
        .map((s) => model.Transaction.fromMap(jsonDecode(s)))
        .toList();
  }

  Future<void> _writeAll(List<model.Transaction> list) async {
    final res = await SharedPreferences.getInstance();
    final jsonList = list.map((transc) => jsonEncode(transc.toMap())).toList();
    await res.setStringList(_transactionsKey, jsonList);
  }

  Future<model.Transaction> insertTransaction(
      model.Transaction transc) async {
    final res = await _readAll();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newTransc = transc.copyWith(id: newId);
    res.insert(0, newTransc);
    await _writeAll(res);
    return newTransc;
  }

  Future<List<model.Transaction>> getAllTransactins() async {
    final res = await _readAll();
    res.sort((a, b) => b.date.compareTo(a.date));
    return res;
  }

  Future<List<model.Transaction>> filterByCategory(String category) async {
    final res = await _readAll();
    return res.where((transac) => transac.category == category).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<model.Transaction>> filterByDateRange(
      DateTime start, DateTime end) async {
    final res = await _readAll();
    return res
        .where((transc) =>
            transc.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            transc.date.isBefore(end.subtract(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteTransaction(int id) async {
    final res = await _readAll();
    res.removeWhere((transc) => transc.id == id);
    await _writeAll(res);
  }

  Future<Map<String, double>> getSummaryTransactions() async {
    final res = await _readAll();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var transc in res) {
      if (transc.type == 'income') {
        totalIncome += transc.amount;
      } else {
        totalExpense += transc.amount;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': totalIncome - totalExpense
    };
  }
}
