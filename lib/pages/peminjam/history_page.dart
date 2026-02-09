import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> _fetchMyHistory() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final res = await supabase
        .from('peminjaman_barang')
        .select('*, pengembalian_barang(Denda)')
        .eq('UserPeminjam', user.id)
        .order('TanggalPinjam', ascending: false);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'My History',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.primary),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchMyHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(child: Text('No history yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              return _historyCard(item);
            },
          );
        },
      ),
    );
  }

  // ================= CARD UI =================

  Widget _historyCard(Map item) {
    final status = item['Status'] as String;
    final int amount = item['BanyakBarang'] ?? 0;
    final String name = item['NamaAlat'] ?? '-';
    final String deadline = item['TanggalKembali'] ?? '-';

    final statusUI = _mapStatus(status);

    int lateFee = 0;
    final pengembalian = item['pengembalian_barang'];
    if (pengembalian is List && pengembalian.isNotEmpty) {
      lateFee = pengembalian.first['Denda'] ?? 0;
    } else if (pengembalian is Map) {
      lateFee = pengembalian['Denda'] ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deadline: $deadline',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text('Amount: $amount', style: const TextStyle(fontSize: 12)),
                if (status == 'overdue') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Late Fee: Rp $lateFee',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // RIGHT STATUS
          Column(
            children: [
              if (statusUI.showIcon)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusUI.textColor, width: 2),
                  ),
                  child: Icon(
                    statusUI.icon,
                    size: 16,
                    color: statusUI.textColor,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusUI.borderColor),
                ),
                child: Text(
                  statusUI.label,
                  style: TextStyle(
                    color: statusUI.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS MAPPER =================

  _StatusUI _mapStatus(String status) {
    switch (status) {
      case 'borrowed':
        return _StatusUI(
          label: 'On Loan',
          borderColor: Colors.green,
          textColor: Colors.green,
        );

      case 'returned':
        return _StatusUI(
          label: 'Returned',
          borderColor: AppColors.primary,
          textColor: AppColors.primary,
        );

      case 'overdue':
        return _StatusUI(
          label: 'Overdue',
          borderColor: Colors.red,
          textColor: Colors.red,
        );

      case 'rejected':
        return _StatusUI(
          label: 'Rejected',
          borderColor: Colors.red,
          textColor: Colors.red,
          icon: Icons.close,
          showIcon: true,
        );

      case 'pending':
      default:
        return _StatusUI(
          label: 'Waiting',
          borderColor: Colors.grey,
          textColor: AppColors.primary,
        );
    }
  }
}

// ================= HELPER CLASS =================

class _StatusUI {
  final String label;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final bool showIcon;

  _StatusUI({
    required this.label,
    required this.borderColor,
    required this.textColor,
    this.icon = Icons.close,
    this.showIcon = false,
  });
}
