import 'package:hive_flutter/hive_flutter.dart';

class Transaction {
  final String id;
  final double amount;
  final String category; 
  final DateTime timestamp;
  final String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.timestamp,
    this.note,
  });
}

// Manual Adapter: No code generation required
class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      id: reader.read() as String,
      amount: reader.read() as double,
      category: reader.read() as String,
      timestamp: reader.read() as DateTime,
      note: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.id);
    writer.write(obj.amount);
    writer.write(obj.category);
    writer.write(obj.timestamp);
    writer.write(obj.note);
  }
}