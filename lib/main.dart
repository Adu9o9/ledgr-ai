import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/transaction_model.dart';
import 'data/models/budget_model.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before accessing local storage
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (Web uses IndexedDB under the hood)
  await Hive.initFlutter();

  // Register the generated adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());

  // Open the NoSQL boxes
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Budget>('budget');

  runApp(
    // Wrap the app in Riverpod's ProviderScope
    const ProviderScope( 
      child: LedgrApp(),
    ),
  );
}

class LedgrApp extends StatelessWidget {
  const LedgrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledgr.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // CRED aesthetic dark mode
      ),
      home: const DashboardScreen(),
    );
  }
}