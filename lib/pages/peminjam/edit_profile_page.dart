import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/peminjam/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? nameError;
  String? addressError;
  String? avatarUrl;
  bool isLoading = true;
  bool isUploadingImage = false;
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('users')
          .select('Nama, Alamat, Foto')
          .eq('id', user.id)
          .single();

      setState(() {
        nameController.text = data['Nama'] ?? '';
        addressController.text = data['Alamat'] ?? '';
        avatarUrl = data['Foto'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load profile error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      nameError = null;
      addressError = null;
    });

    final name = nameController.text.trim();
    final address = addressController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      nameError = 'Name cannot be empty';
      hasError = true;
    } else if (RegExp(r'\d').hasMatch(name)) {
      nameError = 'Name cannot contain numbers';
      hasError = true;
    }

    if (address.isEmpty) {
      addressError = 'Address cannot be empty';
      hasError = true;
    } else if (RegExp(r'\d').hasMatch(address)) {
      addressError = 'Address cannot contain numbers';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      String? uploadedAvatarUrl = avatarUrl;

      if (selectedImageBytes != null) {
        final url = await _uploadImage(selectedImageBytes!);
        if (url != null) {
          uploadedAvatarUrl = url;
        }
      }

      await supabase
          .from('users')
          .update({
            'Nama': nameController.text.trim(),
            'Alamat': addressController.text.trim(),
            'Foto': uploadedAvatarUrl,
          })
          .eq('id', user.id);

      // KIRIM SIGNAL BERHASIL KE PROFILE PAGE
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Update profile error: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  // gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImage(Uint8List bytes) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() => isUploadingImage = true);

      await supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      setState(() => isUploadingImage = false);

      return publicUrl;
    } catch (e) {
      setState(() => isUploadingImage = false);
      debugPrint('Upload image error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // CUSTOM APPBAR
            Container(
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // PROFILE IMAGE
                    Container(
                      width: 200,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                        image: selectedImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(selectedImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : (avatarUrl != null && avatarUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ADD IMAGE
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: isUploadingImage
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Add Image',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: nameController,
                      errorText: nameError,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: addressController,
                      errorText: addressError,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: 180,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) {
              setState(() {
                nameError = null;
                addressError = null;
              });
            },
          ),
        ),

        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
