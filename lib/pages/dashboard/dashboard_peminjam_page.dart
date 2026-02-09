import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/alat_model.dart';
import 'package:flutter_application_1/pages/peminjam/peminjaman_page.dart';
import 'package:flutter_application_1/services/alat_service.dart';
import '../../core/constants/app_colors.dart';

class DashboardPeminjamPage extends StatefulWidget {
  const DashboardPeminjamPage({super.key});

  @override
  State<DashboardPeminjamPage> createState() => _DashboardPeminjamPageState();
}

class _DashboardPeminjamPageState extends State<DashboardPeminjamPage> {
  int selectedCategory = 0;
  String selectedCategoryKey = 'All';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), // TEKS TURUN
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'LAPINBAR',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 16),
            _categoryBar(),
            const SizedBox(height: 16),
            Expanded(child: _itemGrid()),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
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
          hintText: 'Search name or stock',
          prefixIcon: const Icon(Icons.search),

          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,

          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categoryBar() {
    final categories = [
      {'icon': Icons.grid_view, 'label': 'All', 'key': 'All'},
      {'icon': Icons.cable, 'label': 'Cable', 'key': 'Kabel'},
      {'icon': Icons.monitor, 'label': 'Monitors', 'key': 'Monitor'},
      {'icon': Icons.mouse, 'label': 'Mouse', 'key': 'Mouse'},
      {'icon': Icons.keyboard, 'label': 'Keyboard', 'key': 'Keyboard'},
    ];

    return SizedBox(
      height: 85,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 18),
          itemBuilder: (context, index) {
            final item = categories[index];
            final isSelected = selectedCategory == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = index;
                  selectedCategoryKey = item['key'] as String;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 22,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _itemGrid() {
    return FutureBuilder(
      future: AlatService.getAllAlat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allAlat = snapshot.data as List<Alat>;

        List<Alat> filteredByCategory = selectedCategoryKey == 'All'
            ? allAlat
            : allAlat
                  .where(
                    (alat) =>
                        alat.namaKategori.toLowerCase() ==
                        selectedCategoryKey.toLowerCase(),
                  )
                  .toList();

        final alatList = filteredByCategory.where((alat) {
          final nameMatch = alat.namaAlat.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

          final stockMatch = alat.stokBarang.toString().contains(searchQuery);

          return nameMatch || stockMatch;
        }).toList();

        if (alatList.isEmpty) {
          return const Center(child: Text('No product data'));
        }

        return GridView.builder(
          itemCount: alatList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 138 / 165,
          ),
          itemBuilder: (context, index) {
            final alat = alatList[index];

            return _productCard(
              alatId: alat.id,
              name: alat.namaAlat,
              category: alat.namaKategori,
              stock: alat.stokBarang,
              imageUrl: alat.fotoBarang == null || alat.fotoBarang!.isEmpty
                  ? 'https://via.placeholder.com/150'
                  : alat.fotoBarang!,
            );
          },
        );
      },
    );
  }

  Widget _productCard({
    required int alatId,
    required String name,
    required String category,
    required int stock,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 160,
              height: 110,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 14),

          // STOCK + BUTTON MORE
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                // STOCK BOX
                Container(
                  width: 58,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Text(
                    'Stock: $stock',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // MORE BUTTON
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PeminjamanPage(
                          alatId: alatId,
                          name: name,
                          category: category,
                          stock: stock,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 43,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
