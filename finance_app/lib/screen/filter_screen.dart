import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/transaction.dart' as model;

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Date filter
  DateTime? _startDate;
  DateTime? _endDate;

  // Category filter
  String? _selectedCategory;
  final List<String> _allCategories = [
    'Gaji',
    'Freelance',
    'Investasi',
    'Bonus',
    'Makanan',
    'Transportasi',
    'Belanja',
    'Kesehatan',
    'Hiburan',
    'Tagihan',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _applyDateFilter() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tanggal selesai harus setelah tanggal mulai')),
      );
      return;
    }

    final result = await DatabaseHelper.instance.filterByDateRange(
      _startDate!,
      _endDate!.add(const Duration(hours: 23, minutes: 59)),
    );

    if (mounted) Navigator.pop(context, result);
  }

  Future<void> _applyCategoryFilter() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final result = await DatabaseHelper.instance
        .filterByCategory(_selectedCategory!);

    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Filter Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 31, 31, 31),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Berdasarkan Tanggal'),
            Tab(text: 'Berdasarkan Kategori'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDateFilter(),
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('Pilih Rentang Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _buildDateTile(
            label: 'Tanggal Mulai',
            date: _startDate,
            onTap: () => _pickDate(true),
          ),
          const SizedBox(height: 12),
          _buildDateTile(
            label: 'Tanggal Selesai',
            date: _endDate,
            onTap: () => _pickDate(false),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _applyDateFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Terapkan Filter',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            const Icon(Icons.calendar_today_outlined, color: Color.fromARGB(255, 31, 31, 31)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? DateFormat('dd MMMM yyyy').format(date)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: date != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('Pilih Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: _allCategories.length,
              itemBuilder: (context, index) {
                final cat = _allCategories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color.fromARGB(255, 34, 34, 34) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromARGB(255, 32, 32, 32)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _applyCategoryFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 32, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Terapkan Filter',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
