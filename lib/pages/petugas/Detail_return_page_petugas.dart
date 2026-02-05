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

  String condition = 'Good';

  Future<void> _submitReturn() async {
    final int overdueDays = int.tryParse(overdueController.text) ?? 0;
    final int fee = int.tryParse(feeController.text) ?? 0;

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
            'Kondisi': condition,
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
  void initState() {
    super.initState();

    overdueController.text = widget.returnData?.toString() ?? '0';

    feeController.text = widget.returnData?.toString() ?? '0';

    condition = widget.returnData?.toString() ?? 'Good';
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    final bool isFinished =
        widget.returnData == 'returned' ||
        widget.returnData == 'overdue';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _field('Name', loan['UserPeminjam']),
                    _field('Product', loan['NamaAlat']),
                    _field('Amount', loan['BanyakBarang'].toString()),
                    _field('Loan Date', loan['TanggalPinjam']),
                    _field('Return Date', loan['TanggalKembali']),

                    _inputField(
                      'Overdue',
                      overdueController,
                      enabled: !isFinished,
                    ),
                    _inputField('Fee', feeController, enabled: !isFinished),

                    // DROPDOWN KONDISI
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Condition'),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: condition,
                      items: const [
                        DropdownMenuItem(value: 'Good', child: Text('Good')),
                        DropdownMenuItem(
                          value: 'Damaged',
                          child: Text('Damaged'),
                        ),
                        DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                      ],
                      onChanged: isFinished
                          ? null
                          : (val) {
                              setState(() => condition = val!);
                            },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!isFinished)
                      SizedBox(
                        width: 140,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _submitReturn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          'Return already processed (${loan['Status']})',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
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

  Widget _buildHeader() {
    return Row(
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
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
