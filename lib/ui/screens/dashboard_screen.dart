import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neopop/neopop.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/transaction_provider.dart';
import '../../data/repositories/ai_repository.dart'; // Added API Repository

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isAILoading = false; // Tracks API network state

  // --- LOGIC: Fetch AI Insights ---
  Future<void> _fetchAIInsights(WidgetRef ref) async {
    final transactions = ref.read(transactionProvider);
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log some expenses first!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isAILoading = true);

    try {
      // 1. Securely aggregate local data (Privacy-First)
      double total = 0;
      Map<String, double> categoryTotals = {};
      for (var tx in transactions) {
        total += tx.amount;
        categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
      }

      String monthlyData = "Budget: ₹10,000. Total Spent: ₹$total. Categories: ";
      categoryTotals.forEach((cat, amt) {
        monthlyData += "$cat: ₹$amt, ";
      });

      // 2. Call Gemini API
      final insights = await AIRepository.getFinancialAdvice(monthlyData);

      // 3. Display the response
      if (mounted) {
        _showAIResultDialog(insights);
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('AI Error: $e'), backgroundColor: Colors.red)
         );
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  // --- UI: Add Transaction Dialog ---
  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String selectedCategory = 'Food';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOG NEW EXPENSE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8DD04A))),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF222222),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8DD04A))),
                ),
                items: ['Food', 'Transport', 'Shopping', 'Misc'].map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: NeoPopTiltedButton(
                  isFloating: true,
                  onTapUp: () {
                    HapticFeedback.vibrate();
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0) {
                      ref.read(transactionProvider.notifier).addTransaction(amount, selectedCategory, 'Logged Entry');
                      Navigator.pop(context);
                    }
                  },
                  decoration: const NeoPopTiltedButtonDecoration(
                    color: Color(0xFFFFFFFF),
                    plunkColor: Color(0xFFC4C4C4),
                    shadowColor: Colors.black,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: Text('SAVE EXPENSE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }
    );
  }

  // --- UI: Show AI Results Dialog ---
  void _showAIResultDialog(Map<String, dynamic> insights) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF8DD04A)),
                  SizedBox(width: 10),
                  Text('GEMINI INSIGHTS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 20),
              _buildInsightCard(insights['insight_1'] ?? 'Data unavailable.', Colors.redAccent),
              const SizedBox(height: 10),
              _buildInsightCard(insights['insight_2'] ?? 'Data unavailable.', Colors.orangeAccent),
              const SizedBox(height: 10),
              _buildInsightCard(insights['insight_3'] ?? 'Data unavailable.', const Color(0xFF8DD04A)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: NeoPopTiltedButton(
                  isFloating: true,
                  onTapUp: () {
                    HapticFeedback.vibrate();
                    Navigator.pop(context);
                  },
                  decoration: const NeoPopTiltedButtonDecoration(
                    color: Color(0xFF222222),
                    plunkColor: Color(0xFF111111),
                    shadowColor: Colors.black,
                    border: Border.fromBorderSide(BorderSide(color: Colors.grey, width: 1)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(child: Text('DISMISS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInsightCard(String text, Color leftBorderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(left: BorderSide(color: leftBorderColor, width: 4)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final totalSpent = transactions.fold(0.0, (sum, tx) => sum + tx.amount);
    final sortedTx = transactions.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ledgr.ai', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.8)),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL SPENT (AUG)', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text('₹${totalSpent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: totalSpent > 0 ? (totalSpent / 10000).clamp(0.0, 1.0) : 0, 
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DD04A)),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 10),
                    const Text('Budget limit: ₹10,000', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: NeoPopTiltedButton(
                      isFloating: true,
                      onTapUp: () {
                        HapticFeedback.vibrate();
                        _showAddTransactionDialog(context, ref);
                      },
                      decoration: const NeoPopTiltedButtonDecoration(
                        color: Colors.white,
                        plunkColor: Color(0xFFC4C4C4),
                        shadowColor: Colors.black,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: Text('LOG EXPENSE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: NeoPopTiltedButton(
                      isFloating: true,
                      onTapUp: () {
                        HapticFeedback.vibrate();
                        _fetchAIInsights(ref);
                      },
                      decoration: const NeoPopTiltedButtonDecoration(
                        color: Color(0xFF0D0D0D),
                        plunkColor: Color(0xFF3F6915),
                        shadowColor: Colors.black,
                        border: Border.fromBorderSide(BorderSide(color: Color(0xFF8DD04A), width: 1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          // Shows a loading spinner while waiting for Gemini
                          child: _isAILoading 
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Color(0xFF8DD04A), strokeWidth: 2))
                            : const Text('ASK AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text('RECENT TRANSACTIONS', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 10),
              Expanded(
                child: sortedTx.isEmpty 
                  ? const Center(child: Text('No expenses recorded.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: sortedTx.length,
                      itemBuilder: (context, index) {
                        final tx = sortedTx[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('MMM dd, hh:mm a').format(tx.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              Text('-₹${tx.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}