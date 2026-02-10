import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class DataProductPage extends StatefulWidget {
  const DataProductPage({super.key});

  @override
  State<DataProductPage> createState() => _DataProductPageState();
}

class _DataProductPageState extends State<DataProductPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late TabController _tabController;

  bool isLoadingAlat = true;
  bool isLoadingKategori = true;

  List<Map<String, dynamic>> alatList = [];
  List<Map<String, dynamic>> kategoriList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAlat();
    _loadKategori();
  }

  // ================= LOAD DATA =================

  Future<void> _loadAlat() async {
    try {
      setState(() => isLoadingAlat = true);

      final data = await supabase
          .from('alat')
          .select('Alat_ID, NamaAlat, Stok, NamaKategori, FotoBarang');

      setState(() {
        alatList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('ERROR LOAD ALAT: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load alat: $e')));
    } finally {
      setState(() => isLoadingAlat = false);
    }
  }

  Future<void> _loadKategori() async {
    try {
      setState(() => isLoadingKategori = true);

      final data = await supabase
          .from('kategori')
          .select('Kategori_ID, NamaKategori');

      setState(() {
        kategoriList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('ERROR LOAD KATEGORI: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingKategori = false);
      }
    }
  }

  // ================= CRUD ALAT =================

  void _showAlatDialog({Map? alat}) {
    final nameController = TextEditingController(text: alat?['NamaAlat'] ?? '');
    final stokController = TextEditingController(
      text: alat?['Stok']?.toString() ?? '',
    );
    String selectedKategori = alat?['Kategori'] ?? '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          title: Text(
            alat == null ? 'Tambah Alat' : 'Edit Alat',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Alat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),

                // DROPDOWN KATEGORI
                DropdownButtonFormField<String>(
                  value: selectedKategori.isEmpty ? null : selectedKategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: kategoriList.map((k) {
                    final nama = k['NamaKategori'] as String;
                    return DropdownMenuItem(value: nama, child: Text(nama));
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedKategori = val ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    stokController.text.isEmpty ||
                    selectedKategori.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi semua data!')),
                  );
                  return;
                }

                try {
                  if (alat == null) {
                    await supabase.from('alat').insert({
                      'NamaAlat': nameController.text.trim(),
                      'Stok': int.tryParse(stokController.text) ?? 0,
                      'NamaKategori': selectedKategori,
                    });
                  } else {
                    await supabase
                        .from('alat')
                        .update({
                          'NamaAlat': nameController.text.trim(),
                          'Stok': int.tryParse(stokController.text) ?? 0,
                          'NamaKategori': selectedKategori,
                        })
                        .eq('Alat_ID', alat['Alat_ID']);
                  }
                  Navigator.pop(context);
                  _loadAlat();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAlat(int alatId) async {
    await supabase.from('alat').delete().eq('Alat_ID', alatId);
    _loadAlat();
  }

  // ================= CRUD KATEGORI =================

  void _showKategoriDialog({Map? kategori}) {
    final controller = TextEditingController(
      text: kategori?['NamaKategori'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(kategori == null ? 'Add Kategori' : 'Edit Kategori'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (kategori == null) {
                await supabase.from('kategori').insert({
                  'NamaKategori': controller.text,
                });
              } else {
                await supabase
                    .from('kategori')
                    .update({'NamaKategori': controller.text})
                    .eq('Kategori_ID', kategori['Kategori_ID']);
              }

              Navigator.pop(context);
              _loadKategori();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteKategori(int id) async {
    await supabase.from('kategori').delete().eq('Kategori_ID', id);
    _loadKategori();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ===== TOP BAR =====
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      const SizedBox(width: 14),

                      // ===== TITLE CENTER =====
                       Center(
                          child: Text(
                            'Master Data',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                      // Spacer biar title tetap center
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // ===== TAB BAR =====
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.inventory), text: 'Alat'),
                    Tab(icon: Icon(Icons.category), text: 'Kategori'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (_tabController.index == 0) {
            _showAlatDialog();
          } else {
            _showKategoriDialog();
          }
        },
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // ============ TAB ALAT ============
          isLoadingAlat
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : alatList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data alat',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: alatList.length,
                    itemBuilder: (context, index) {
                      final alat = alatList[index];
                      return _alatCard(alat);
                    },
                  ),
                ),

          // ============ TAB KATEGORI ============
          isLoadingKategori
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : kategoriList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada kategori',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kategoriList.length,
                  itemBuilder: (context, index) {
                    final kategori = kategoriList[index];
                    return _kategoriCard(kategori);
                  },
                ),
        ],
      ),
    );
  }

  Widget _alatCard(Map alat) {
    final String? foto = alat['FotoBarang'];
    final imageUrl = foto != null && foto.isNotEmpty
        ? foto
        : 'https://via.placeholder.com/150?text=No+Image';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat['NamaAlat'] ?? 'Nama tidak tersedia',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Stok: ${alat['Stok'] ?? 0}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                Text(
                  'Kategori: ${alat['Kategori'] ?? '-'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 22,
                      ),
                      onPressed: () => _showAlatDialog(alat: alat),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 22,
                      ),
                      onPressed: () => _deleteAlat(alat['Alat_ID']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kategoriCard(Map kategori) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.category, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              kategori['NamaKategori'] ?? 'Nama tidak tersedia',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showKategoriDialog(kategori: kategori),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteKategori(kategori['Kategori_ID']),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
