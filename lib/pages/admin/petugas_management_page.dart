import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/add_petugas_page.dart';
import 'package:flutter_application_1/pages/admin/edit_profile_officer_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class PetugasManagementPage extends StatefulWidget {
  const PetugasManagementPage({super.key});

  @override
  State<PetugasManagementPage> createState() => _PetugasManagementPageState();
}

class _PetugasManagementPageState extends State<PetugasManagementPage> {
  final searchController = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> petugasList = [];

  @override
  void initState() {
    super.initState();
    _loadPetugas();
  }

  Future<void> _loadPetugas({String? keyword}) async {
    final supabase = Supabase.instance.client;

    var query = supabase
        .from('users')
        .select('id, Nama, Alamat, Foto, Role')
        .eq('Role', 'Officer');

    if (keyword != null && keyword.isNotEmpty) {
      query = query.or('Nama.ilike.%$keyword%,Alamat.ilike.%$keyword%');
    }

    final data = await query;

    setState(() {
      petugasList = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Floatingbutton
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetugasPage()),
          ).then((_) => _loadPetugas());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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
                  'Officer',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search name or address...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (value) {
                          _loadPetugas(keyword: value);
                        },
                      ),
                    ),
                  ),

                  // Grid Officer Cards
                  isLoading
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: petugasList.length,
                            itemBuilder: (context, index) {
                              final petugas = petugasList[index];
                              return _OfficerCard(
                                id: petugas['id'],
                                nama: petugas['Nama'] ?? '',
                                alamat: petugas['Alamat'] ?? '',
                                fotoUrl: petugas['Foto'],
                                onUpdated: _loadPetugas,
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerCard extends StatelessWidget {
  final String id;
  final String nama;
  final String alamat;
  final String? fotoUrl;
  final VoidCallback onUpdated;

  const _OfficerCard({
    required this.id,
    required this.nama,
    required this.alamat,
    this.fotoUrl,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: fotoUrl != null && fotoUrl!.isNotEmpty
                      ? Image.network(
                          fotoUrl!,
                          width: 160,
                          height: 105,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                ),

                const SizedBox(height: 8),

                Divider(color: Colors.grey.shade300, thickness: 1),

                const SizedBox(height: 6),

                // Nama
                Text(
                  nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                // Alamat
                Text(
                  alamat,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Tombol Edit
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit_square, size: 16),
                color: AppColors.primary,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileAdminPage(officerId: id),
                    ),
                  );
                  if (result == true) {
                    onUpdated();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
