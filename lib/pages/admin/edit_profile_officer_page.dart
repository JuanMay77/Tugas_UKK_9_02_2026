import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/peminjam/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class EditProfileAdminPage extends StatefulWidget {
  final String officerId;

  const EditProfileAdminPage({super.key, required this.officerId});

  @override
  State<EditProfileAdminPage> createState() => _EditProfileAdminPageState();
}

class _EditProfileAdminPageState extends State<EditProfileAdminPage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final addressController = TextEditingController();

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
      final data = await supabase
          .from('users')
          .select('Nama, Alamat, Foto')
          .eq('id', widget.officerId)
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

  Future<void> _deleteOfficer() async {
    try {
      await supabase.from('users').delete().eq('id', widget.officerId);

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer deleted successfully')),
      );
    } catch (e) {
      debugPrint('Delete officer error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_forever, color: Colors.red, size: 64),

              const SizedBox(height: 16),

              const Text(
                'Are you sure you want to delete this officer?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // NO
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // YES
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); 
                        await _deleteOfficer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          .eq('id', widget.officerId);

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
      final fileName =
          '${widget.officerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 26),
                    onPressed: _showDeleteDialog,
                  ),
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
