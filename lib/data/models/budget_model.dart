import 'package:hive_flutter/hive_flutter.dart';

class Budget {
  final double monthlyLimit;
  final double savedSoFar;

  Budget({
    required this.monthlyLimit,
    required this.savedSoFar,
  });
}

// Manual Adapter: No code generation required
class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 1;

  @override
  Budget read(BinaryReader reader) {
    return Budget(
      monthlyLimit: reader.read() as double,
      savedSoFar: reader.read() as double,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.write(obj.monthlyLimit);
    writer.write(obj.savedSoFar);
  }
}