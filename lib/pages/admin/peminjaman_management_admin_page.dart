import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanManagementAdminPage extends StatefulWidget {
  const LoanManagementAdminPage({super.key});

  @override
  State<LoanManagementAdminPage> createState() =>
      _LoanManagementAdminPageState();
}

class _LoanManagementAdminPageState extends State<LoanManagementAdminPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String getImageUrl(String? url) {
    return url ?? '';
  }

  String selectedTab = 'pending';
  String searchQuery = '';

  Future<List<dynamic>> _fetchLoans() async {
    final res = await supabase
        .from('peminjaman_barang')
        .select('*, alat(FotoBarang)')
        .eq('Status', selectedTab)
        .order('TanggalPinjam', ascending: false);

    if (searchQuery.isEmpty) return res;

    return res.where((item) {
      final name = item['NamaUser']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

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

      setState(() {
        selectedTab = 'borrowed';
      });
      _showSnack('Loan approved & stock updated');
    } catch (e) {
      _showSnack('Failed to approve: $e');
    }
  }

  Future<void> _rejectLoan(Map loan, String reason) async {
    try {
      await supabase
          .from('peminjaman_barang')
          .update({'Status': 'rejected', 'AlasanPenolakan': reason})
          .eq('Peminjaman_ID', loan['Peminjaman_ID']);

      setState(() {
        selectedTab = 'rejected';
      });
      _showSnack('Loan rejected');
    } catch (e) {
      _showSnack('Failed to reject: $e');
    }
  }

  Widget _statusBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Loan Management',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= SEARCH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearch(),
            ),

            const SizedBox(height: 20),

            // ================= TABS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('pending', 'Waiting'),
                  const SizedBox(width: 12),
                  _buildTab('borrowed', 'Approved'),
                  const SizedBox(width: 12),
                  _buildTab('rejected', 'Declined'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= LIST =================
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchLoans(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text('No loans found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _approvalCard(data[index]); // DASHBOARD STYLE
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

  // ================= SEARCH WIDGET =================

  Widget _buildSearch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ================= TAB =================

  Widget _buildTab(String value, String label) {
    final isActive = selectedTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = value),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= DASHBOARD APPROVAL CARD STYLE =================

  Widget _approvalCard(Map loan) {
    final imageUrl = loan['alat']?['FotoBarang'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: imageUrl != null && imageUrl.toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    ),
                  )
                : const Icon(Icons.inventory_2),
          ),

          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan['NamaAlat'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Loan Date: ${loan['TanggalPinjam']}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Amount: ${loan['BanyakBarang']}',
                  style: const TextStyle(fontSize: 11),
                ),
                if (selectedTab == 'rejected' &&
                    loan['AlasanPenolakan'] != null &&
                    loan['AlasanPenolakan'].toString().isNotEmpty)
                  Text(
                    'Reason: ${loan['AlasanPenolakan']}',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),

          // BUTTONS
          Builder(
            builder: (_) {
              if (selectedTab == 'pending') {
                return Row(
                  children: [
                    _smallPrimaryBtn('Yes', () => _showApproveDialog(loan)),
                    const SizedBox(width: 8),
                    _smallOutlineBtn('No', () => _showRejectDialog(loan)),
                  ],
                );
              }

              if (selectedTab == 'borrowed') {
                return _statusBadge(text: 'Approved', color: Colors.green);
              }

              if (selectedTab == 'rejected') {
                return _statusBadge(text: 'Declined', color: Colors.red);
              }
              return const SizedBox.shrink();
            },
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
          side: BorderSide(color: AppColors.primary),
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
        child: const Text(
          'Yes',
          style: TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
    );
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
            const Text('Approve loan for', textAlign: TextAlign.center),
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
}
