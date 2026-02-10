import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/pages/petugas/Detail_return_page_petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReturnManagementAdminPage extends StatefulWidget {
  const ReturnManagementAdminPage({super.key});

  @override
  State<ReturnManagementAdminPage> createState() => _ReturnManagementAdminPageState();
}

class _ReturnManagementAdminPageState extends State<ReturnManagementAdminPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String selectedTab = 'waiting';

  Future<List<dynamic>> _fetchReturns() async {
    final res = await supabase
        .from('pengembalian_barang')
        .select('*, peminjaman_barang(*)')
        .eq('Status', selectedTab)
        .order('created_at', ascending: false);

    if (searchQuery.isEmpty) return res;

    return res.where((item) {
      final loan = item['peminjaman_barang'];
      final name = loan?['NamaUser']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                  'Return Management',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tabs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('waiting', 'Waiting'),
                  const SizedBox(width: 12),
                  _buildTab('returned', 'Returned'),
                  const SizedBox(width: 12),
                  _buildTab('overdue', 'Overdue'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Returns List
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchReturns(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items have been borrowed yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return _buildReturnCard(item);
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
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnCard(Map item) {
    final loan = item['peminjaman_barang'];
    final String userName = loan?['NamaUser']?.toString() ?? 'Unknown User';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailReturnPagePetugas(loan: loan, returnData: item),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary, size: 30),
          ],
        ),
      ),
    );
  }
}
