import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db//db_helper.dart';
import '../models/transaction.dart' as model;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'income';
  String _category = 'Gaji';
  DateTime _selectedDate = DateTime.now();

  final List<String> _incomeCategories = [
    'Gaji',
    'Freelance',
    'Investasi',
    'Bonus',
    'Lainnya',
  ];

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Kesehatan',
    'Hiburan',
    'Tagihan',
    'Pendidikan',
    'Lainnya',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transc = model.Transaction(
      title: _titleController.text.trim(),
      desc: _descController.text.trim(),
      category: _category,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      type: _type,
      date: _selectedDate,
    );

    await DatabaseHelper.instance.insertTransaction(transc);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 41, 41, 41),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              _buildSectionTitle('Jenis Transaksi'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(bottom: 4)),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Pemasukan',
                      icon: Icons.arrow_upward,
                      value: 'income',
                      activeColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Pengeluaran',
                      icon: Icons.arrow_downward,
                      value: 'expense',
                      activeColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              _buildSectionTitle('Judul'),
              const SizedBox(height: 8),
              _buildCard(
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan judul transaksi',
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              _buildSectionTitle('Deskripsi'),
              const SizedBox(height: 8),
              _buildCard(
                child: TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan deskripsi transaksi',
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              _buildSectionTitle('Jumlah (Rp)'),
              const SizedBox(height: 8),
              _buildCard(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                    final amount = double.tryParse(v.replaceAll(',', ''));
                    if (amount == null || amount <= 0) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Category
              _buildSectionTitle('Kategori'),
              const SizedBox(height: 8),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _categories.contains(_category)
                      ? _category
                      : _categories.first,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date
              _buildSectionTitle('Tanggal'),
              const SizedBox(height: 8),
              _buildCard(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                        .format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required String value,
    required Color activeColor,
  }) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = value;
          _category = _categories.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
