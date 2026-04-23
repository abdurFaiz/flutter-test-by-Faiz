import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/transaction.dart' as model;
import 'add_transc_screen.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<model.Transaction> _transactions = [];
  Map<String, double> _summary = {
    'totalIncome': 0,
    'totalExpense': 0,
    'netBalance': 0
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final transactions = await DatabaseHelper.instance.getAllTransactins();
    final summary = await DatabaseHelper.instance.getSummaryTransactions();
    setState(() {
      _transactions = transactions;
      _summary = summary;
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(amount);
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Finance Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 35, 35, 35),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () async {
              final filtered = await Navigator.push<List<model.Transaction>>(
                context,
                MaterialPageRoute(builder: (_) => const FilterScreen()),
              );
              if (filtered != null) {
                setState(() => _transactions = filtered);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Belum ada transaksi',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionCard(_transactions[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          _loadData();
        },
        backgroundColor: const Color.fromARGB(255, 46, 46, 46),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 46, 46, 46), Color.fromARGB(255, 71, 71, 71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          const Text('Total Saldo',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(_summary['netBalance']!),
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Pemasukan',
                  _summary['totalIncome']!,
                  Icons.arrow_upward,
                  Colors.greenAccent,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  'Pengeluaran',
                  _summary['totalExpense']!,
                  Icons.arrow_downward,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTransactionCard(model.Transaction transaction) {
    final isIncome = transaction.type == 'income';
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTransaction(transaction.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? Colors.green : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.desc,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.category,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(transaction.date),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
