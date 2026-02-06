import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanManagementPage extends StatefulWidget {
  const LoanManagementPage({super.key});

  @override
  State<LoanManagementPage> createState() => _LoanManagementPageState();
}

class _LoanManagementPageState extends State<LoanManagementPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return supabase.storage.from('products').getPublicUrl(path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildTab('declined', 'Declined'),
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
    final imagePath = loan['alat']?['FotoBarang'];
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
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      getImageUrl(imagePath),
                      fit: BoxFit.cover,
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
              ],
            ),
          ),

          // BUTTONS
          Row(
            children: [
              _smallPrimaryBtn('Yes', () {}),
              const SizedBox(width: 8),
              _smallOutlineBtn('No', () {}),
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
}
