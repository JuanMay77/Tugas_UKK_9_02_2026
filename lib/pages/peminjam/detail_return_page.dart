import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class DetailReturnPage extends StatefulWidget {
  final Map item;

  const DetailReturnPage({super.key, required this.item});

  @override
  State<DetailReturnPage> createState() => _DetailReturnPageState();
}

class _DetailReturnPageState extends State<DetailReturnPage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Return',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _inputBox(label: 'Name', value: item['NamaAlat']),
            _inputBox(label: 'Amount', value: item['BanyakBarang'].toString()),
            _inputBox(label: 'Loan Date', value: item['TanggalPinjam']),
            _inputBox(label: 'Return Date', value: item['TanggalKembali']),

            const SizedBox(height: 30),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _handleReturnRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Return Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // ================= UI INPUT BOX =================

  Widget _inputBox({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ================= LOGIC RETURN =================

  Future<void> _handleReturnRequest() async {
    try {
      final String peminjamanId = widget.item['Peminjaman_ID'];

      await supabase
          .from('peminjaman_barang')
          .update({'Status': 'return_requested'})
          .eq('Peminjaman_ID', peminjamanId);

      await supabase.from('pengembalian_barang').insert({
        'Peminjaman_ID': peminjamanId,
        'Status': 'waiting',
      });

      Navigator.pop(context, true);

    } catch (e) {
      debugPrint('Return request error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}
