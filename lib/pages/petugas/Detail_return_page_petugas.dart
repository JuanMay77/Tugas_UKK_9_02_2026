import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailReturnPagePetugas extends StatefulWidget {
  final Map loan;
  final Map? returnData;

  const DetailReturnPagePetugas({
    super.key,
    required this.loan,
    this.returnData,
  });

  @override
  State<DetailReturnPagePetugas> createState() =>
      _DetailReturnPagePetugasState();
}

class _DetailReturnPagePetugasState extends State<DetailReturnPagePetugas> {
  final supabase = Supabase.instance.client;

  final overdueController = TextEditingController(text: '0');
  final feeController = TextEditingController(text: '0');

  static const int dendaPerHari = 50000;

  @override
  void initState() {
    super.initState();

    overdueController.addListener(() {
      final days = int.tryParse(overdueController.text) ?? 0;
      final total = days * dendaPerHari;
      feeController.text = total.toString();
    });
  }

  Future<void> _submitReturn() async {
    final int overdueDays = int.tryParse(overdueController.text) ?? 0;
    final int fee = overdueDays * dendaPerHari;

    try {
      final newStatus = overdueDays > 0 ? 'overdue' : 'returned';

      await supabase
          .from('peminjaman_barang')
          .update({
            'Status': newStatus,
            'TanggalKembali': DateTime.now().toIso8601String().substring(0, 10),
          })
          .eq('Peminjaman_ID', widget.loan['Peminjaman_ID']);

      await supabase
          .from('pengembalian_barang')
          .update({
            'Status': newStatus,
            'Terlambat': overdueDays,
            'Denda': fee,
            'TanggalKembali': DateTime.now().toIso8601String().substring(0, 10),
          })
          .eq('Peminjaman_ID', widget.loan['Peminjaman_ID']);

      final alatRes = await supabase
          .from('alat')
          .select('Stok')
          .eq('Alat_ID', widget.loan['Alat_ID'])
          .single();

      final int currentStock = alatRes['Stok'];

      await supabase
          .from('alat')
          .update({'Stok': currentStock + widget.loan['BanyakBarang']})
          .eq('Alat_ID', widget.loan['Alat_ID']);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _fieldCard('Name', loan['UserPeminjam']),
                    _fieldCard('Product', loan['NamaAlat']),
                    _fieldCard('Amount', loan['BanyakBarang'].toString()),
                    _fieldCard('Loan Date', loan['TanggalPinjam']),
                    _fieldCard('Return Date', loan['TanggalKembali'] ?? '-'),

                    _inputCard('Overdue (Days)', overdueController),
                    _inputCard('Fee (Auto)', feeController, enabled: false),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: 160,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _submitReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Submit Return',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Detail Return',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _fieldCard(String label, String value) {
    return _baseCard(
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _inputCard(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return _baseCard(
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _baseCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
