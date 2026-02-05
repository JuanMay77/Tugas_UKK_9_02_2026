import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/peminjam/detail_return_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> _fetchReturnList() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('peminjaman_barang')
        .select()
        .eq('UserPeminjam', user.id)
        .inFilter('Status', ['borrowed', 'return_requested'])
        .order('TanggalKembali', ascending: true);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchReturnList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(child: Text('No items to return'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _returnCard(data[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Return',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _returnCard(Map item) {
    return InkWell(
      onTap: () async {
       final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailReturnPage(item: item)),
        );
        if (result == true) {
    setState(() {});
        }
      },
      child: _returnCardContent(item),
    );
  }

  Widget _returnCardContent(Map item) {
    final String name = item['NamaAlat'] ?? '-';
    final int amount = item['BanyakBarang'] ?? 0;
    final String returnDateStr = item['TanggalKembali'];
    final String status = item['Status'] ?? '';

    final deadline = DateTime.parse(returnDateStr);
    final now = DateTime.now();

    final diffDays = deadline.difference(now).inDays;

    late String statusText;
    late Color statusColor;

    if (diffDays > 1) {
      statusText = '$diffDays more day';
      statusColor = Colors.green;
    } else if (diffDays == 1) {
      statusText = '1 more day';
      statusColor = Colors.orange;
    } else if (diffDays == 0) {
      statusText = 'Due today';
      statusColor = Colors.orange;
    } else {
      statusText = '${diffDays.abs()} day late';
      statusColor = Colors.red;
    }

    final bool isWaiting = status == 'return_requested';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Loan Date: $returnDateStr',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text('Amount: $amount', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                if (isWaiting) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Waiting for confirmation...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // RIGHT ARROW
          Icon(Icons.chevron_right, color: AppColors.primary, size: 28),
        ],
      ),
    );
  }
}
