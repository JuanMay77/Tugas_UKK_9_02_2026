import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPetugasPage extends StatefulWidget {
  const AddPetugasPage({super.key});

  @override
  State<AddPetugasPage> createState() => _AddPetugasPageState();
}

class _AddPetugasPageState extends State<AddPetugasPage> {
  final supabase = Supabase.instance.client;

  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final namaC = TextEditingController();
  final alamatC = TextEditingController();

  String? nameError;
  String? addressError;
  String? emailError;
  String? passwordError;

  String role = 'Officer';
  bool isLoading = false;

  Future<void> _submit() async {
    setState(() {
      nameError = null;
      addressError = null;
      emailError = null;
      passwordError = null;
    });

    bool hasError = false;

    if (namaC.text.trim().isEmpty) {
      nameError = 'Name cannot be empty';
      hasError = true;
    }

    if (alamatC.text.trim().isEmpty) {
      addressError = 'Address cannot be empty';
      hasError = true;
    }

    if (emailC.text.trim().isEmpty) {
      emailError = 'Email cannot be empty';
      hasError = true;
    }

    if (passwordC.text.trim().length < 6) {
      passwordError = 'Password min 6 characters';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    try {
      setState(() => isLoading = true);

      final authRes = await supabase.auth.signUp(
        email: emailC.text.trim(),
        password: passwordC.text.trim(),
      );

      final userId = authRes.user!.id;

      await supabase
          .from('users')
          .update({
            'Nama': namaC.text.trim(),
            'Alamat': alamatC.text.trim(),
            'Role': role,
            'Foto': null,
          })
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Petugas berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= CUSTOM APPBAR =================
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
                        'Add Officer',
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

            // ================= FORM =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: namaC,
                      errorText: nameError,
                      hintText: 'Enter full name',
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: alamatC,
                      errorText: addressError,
                      hintText: 'Enter address',
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailC,
                      errorText: emailError,
                      hintText: 'example@email.com',
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: passwordC,
                      errorText: passwordError,
                      obscureText: true,
                      hintText: 'Minimum 6 characters',
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: 180,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit',
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

  // ================= UI HELPERS =================

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
    bool obscureText = false,
    String? hintText,
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
            obscureText: obscureText,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) {
              setState(() {
                nameError = null;
                addressError = null;
                emailError = null;
                passwordError = null;
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
