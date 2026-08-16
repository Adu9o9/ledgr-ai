import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

// The Riverpod provider that the UI will listen to
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    _loadTransactions();
  }

  final _box = Hive.box<Transaction>('transactions');

  // Load all transactions from local storage into memory
  void _loadTransactions() {
    state = _box.values.toList().cast<Transaction>();
  }

  // Add a new transaction and update the UI instantly
  Future<void> addTransaction(double amount, String category, String? note) async {
    final newTx = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      timestamp: DateTime.now(),
      note: note,
    );
    
    await _box.add(newTx);
    state = [...state, newTx]; // Triggers UI rebuild
  }
}