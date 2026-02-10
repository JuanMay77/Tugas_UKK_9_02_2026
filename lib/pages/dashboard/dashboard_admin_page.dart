import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

int waitingCount = 0;
int onLoanCount = 0;
int overdueCount = 0;
int returnedTodayCount = 0;

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _rejectReasonCtrl = TextEditingController();

  void _showRejectDialog(Map loan) {
    _rejectReasonCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: const Text(
                      'Rejection Reason',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // TEXTFIELD
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _rejectReasonCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter the reason for rejection...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SUBMIT BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final reason = _rejectReasonCtrl.text.trim();

                    if (reason.isEmpty) {
                      _showSnack('Please enter rejection reason');
                      return;
                    }

                    Navigator.pop(context);
                    await _rejectLoan(loan, reason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getImageUrl(String? url) {
    return url ?? '';
  }

  Future<List<dynamic>> _fetchPendingLoans() async {
    return await supabase
        .from('peminjaman_barang')
        .select('*, alat(FotoBarang)')
        .eq('Status', 'pending')
        .order('TanggalPinjam', ascending: false);
  }

  Future<void> _rejectLoan(Map loan, String reason) async {
  try {
    await supabase
        .from('peminjaman_barang')
        .update({'Status': 'rejected', 'AlasanPenolakan': reason})
        .eq('Peminjaman_ID', loan['Peminjaman_ID']);  

    await _fetchStats();
    setState(() {});
    _showSnack('Peminjaman ditolak');
  } catch (e) {
    _showSnack('Gagal menolak: $e');
  }
}

  Future<void> _fetchStats() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final waitingRes = await supabase
        .from('peminjaman_barang')
        .select('Peminjaman_ID')
        .eq('Status', 'pending');

    final onLoanRes = await supabase
        .from('peminjaman_barang')
        .select('Peminjaman_ID')
        .eq('Status', 'borrowed');

    final overdueRes = await supabase
        .from('peminjaman_barang')
        .select('Peminjaman_ID')
        .eq('Status', 'overdue');

    final returnedTodayRes = await supabase
        .from('peminjaman_barang')
        .select('Peminjaman_ID')
        .eq('Status', 'returned')
        .eq('TanggalKembali', today);

    setState(() {
      waitingCount = waitingRes.length;
      onLoanCount = onLoanRes.length;
      overdueCount = overdueRes.length;
      returnedTodayCount = returnedTodayRes.length;
    });
  }

  // ── BARU: Ambil data log aktivitas ────────────────────────────────
  Future<List<dynamic>> _fetchActivityLog() async {
    return await supabase
        .from('log_aktivitas')
        .select('Log_ID, UserID, Aktivitas, TanggalAktivitas, NamaUser')
        .order('TanggalAktivitas', ascending: false)
        .limit(15);
  }

  // ── BARU: Format waktu relatif (baru saja, 5 menit lalu, dst) ─────
  String _formatWaktu(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'baru saja';
      }
    } catch (e) {
      return timestamp;
    }
  }

  // ── BARU: Kartu setiap aktivitas ──────────────────────────────────
  Widget _kartuAktivitas(Map activity) {
    final String aksi = activity['Aktivitas'] ?? 'Aksi tidak diketahui';
    final String nama = activity['NamaUser'] ?? 'Pengguna tidak diketahui';
    final String waktu = activity['TanggalAktivitas'] != null
        ? _formatWaktu(activity['TanggalAktivitas'])
        : '—';

    if (aksi.toLowerCase().contains('pinjam') ||
        aksi.toLowerCase().contains('peminjaman')) {
    } else if (aksi.toLowerCase().contains('kembali') ||
        aksi.toLowerCase().contains('return')) {
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aksi,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'oleh $nama',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Text(
            waktu,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ── BARU: Daftar log aktivitas ────────────────────────────────────
  Widget _daftarLogAktivitas() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchActivityLog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load log: ${snapshot.error}'),
          );
        }

        final aktivitas = snapshot.data ?? [];

        if (aktivitas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'There is no recent activity yet',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: aktivitas.map((act) => _kartuAktivitas(act)).toList(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 12),
              _statSection(),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Awaiting Approval',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              _approvalList(),
              const SizedBox(height: 32),

              // ── BAGIAN BARU: LOG AKTIVITAS ────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Log Aktivitas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              _daftarLogAktivitas(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Column(
      children: [
        // APPBAR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 28, 20, 10),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'LAPINBAR',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                const Text(
                  'Welcome Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= STAT =================

  Widget _statSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _statCard(waitingCount, 'Waiting for Approval', false),
            _statCard(onLoanCount, 'On Loan', true),
            _statCard(overdueCount, 'Overdue Return', true),
            _statCard(returnedTodayCount, 'Returned Today', false),
          ],
        ),
      ),
    );
  }

  Widget _statCard(int number, String title, bool filled) {
    return Container(
      width: 155,
      height: 85,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: filled
            ? null
            : Border.all(color: Colors.grey.shade300, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$number',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: filled ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= APPROVAL LIST =================

  Widget _approvalList() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchPendingLoans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final loans = snapshot.data ?? [];

        if (loans.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No pending loans'),
          );
        }

        return Column(
          children: loans.map((loan) => _approvalCard(loan)).toList(),
        );
      },
    );
  }

  // ================= APPROVAL CARD =================

  Widget _approvalCard(Map loan) {
    final imagePath = loan['alat']?['FotoBarang'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGE
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: imagePath != null && imagePath.toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      getImageUrl(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : const Icon(Icons.inventory_2, size: 22),
          ),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan['NamaAlat'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Loan Date: ${loan['TanggalPinjam']}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Amount: ${loan['BanyakBarang']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          // BUTTONS
          Row(
            children: [
              _smallPrimaryBtn('Yes', () => _showApproveDialog(loan)),
              const SizedBox(height: 12, width: 10),
              _smallOutlineBtn('No', () => _showRejectDialog(loan)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallOutlineBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: 44,
      height: 22,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _smallPrimaryBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: 44,
      height: 22,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: Colors.white)),
      ),
    );
  }

  // ================= APPROVE =================

  Future<void> _approveLoan(Map loan) async {
    try {
      final int alatId = loan['Alat_ID'];
      final int amount = loan['BanyakBarang'];

      final alatRes = await supabase
          .from('alat')
          .select('Stok')
          .eq('Alat_ID', alatId)
          .single();

      final int currentStock = alatRes['Stok'];

      if (currentStock < amount) {
        _showSnack('Stock not enough!');
        return;
      }

      await supabase
          .from('alat')
          .update({'Stok': currentStock - amount})
          .eq('Alat_ID', alatId);

      await supabase
          .from('peminjaman_barang')
          .update({'Status': 'borrowed'})
          .eq('Peminjaman_ID', loan['Peminjaman_ID']);

      await _fetchStats();
      setState(() {});
      _showSnack('Loan approved & stock updated');
    } catch (e) {
      _showSnack('Failed to approve: $e');
    }
  }

  void _showApproveDialog(Map loan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Approve Loan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Approve loan for', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              '"${loan['NamaAlat']}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Amount: ${loan['BanyakBarang']}',
              textAlign: TextAlign.center,
            ),
          ],
        ),

        actionsAlignment: MainAxisAlignment.center,

        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(90, 40),
            ),
            child: const Text('No', style: TextStyle(color: AppColors.primary)),
          ),

          const SizedBox(width: 12),

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _approveLoan(loan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(90, 40),
            ),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
