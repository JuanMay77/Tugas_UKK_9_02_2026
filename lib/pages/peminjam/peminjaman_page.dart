import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class PeminjamanPage extends StatefulWidget {
  final int alatId;
  final String name;
  final String category;
  final int stock;
  final String imageUrl;

  const PeminjamanPage({
    super.key,
    required this.alatId,
    required this.name,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final stockController = TextEditingController();
  final loanDateController = TextEditingController();
  final returnDateController = TextEditingController();

  int amount = 1;
  bool isSubmitting = false;
  String? amountError;
  int realStock = 0;
  bool isLoadingStock = true;

  @override
  void initState() {
    super.initState();

    // SET DATA DARI DASHBOARD
    nameController.text = widget.name;
    categoryController.text = widget.category;

    final now = DateTime.now();
    final returnDate = now.add(const Duration(days: 3));

    loanDateController.text = _formatDate(now);
    returnDateController.text = _formatDate(returnDate);

    _fetchRealStock();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ================= AMOUNT CONTROL =================

  void _increaseAmount() {
    if (amount < realStock) {
      setState(() {
        amount++;
        amountError = null;
      });
    } else {
      setState(() {
        amountError = 'Amount cannot exceed stock';
      });
    }
  }

  void _decreaseAmount() {
    if (amount > 1) {
      setState(() {
        amount--;
        amountError = null;
      });
    }
  }

  // ================= SUBMIT =================

  Future<void> _submitPeminjaman() async {
    setState(() => amountError = null);

    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnack('User not logged in');
      return;
    }

    if (amount > realStock) {
      setState(() => amountError = 'Amount cannot exceed stock');
      return;
    }

    if (realStock == 0) {
      amountError = 'Stock is empty';
    }

    setState(() => isSubmitting = true);

    try {
      final profile = await supabase
          .from('users')
          .select('Nama')
          .eq('id', user.id)
          .single();

      final String namaUser = profile['Nama'];

      await supabase.from('peminjaman_barang').insert({
        'Alat_ID': widget.alatId,
        'UserPeminjam': user.id,
        'NamaUser': namaUser,
        'NamaAlat': widget.name,
        'TanggalPinjam': loanDateController.text,
        'TanggalKembali': returnDateController.text,
        'Status': 'pending',
        'Stok': widget.stock,
        'Kategori': widget.category,
        'BanyakBarang': amount,
      });

      await supabase.from('log_aktivitas').insert({
      'UserID': user.id,
      'NamaUser': namaUser,
      'Aktivitas': 'peminjaman barang',
    });

      _showSnack('Peminjaman berhasil disubmit');
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Submit error: $e');
      _showSnack('Submit failed: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _fetchRealStock() async {
    try {
      final res = await supabase
          .from('alat')
          .select('Stok')
          .eq('Alat_ID', widget.alatId)
          .single();

      setState(() {
        realStock = res['Stok'] as int;
        stockController.text = realStock.toString();
        isLoadingStock = false;
      });
    } catch (e) {
      debugPrint('Fetch stock error: $e');
      realStock = widget.stock; // fallback
      isLoadingStock = false;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // IMAGE
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    _buildTextField(controller: nameController, enabled: false),

                    const SizedBox(height: 16),

                    _buildLabel('Category'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: categoryController,
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Stock'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: stockController,
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Loan Date'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: loanDateController,
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Return Date'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: returnDateController,
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Amount'),
                    const SizedBox(height: 8),
                    _buildAmountField(),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: 180,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitPeminjaman,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
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

  // ================= WIDGETS =================

  Widget _buildAppBar() {
    return Container(
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
            child: Icon(Icons.arrow_back, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Center(
              child: Text(
                'Detail Product',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: amountError != null ? Colors.red : Colors.grey.shade300,
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
          child: Row(
            children: [
              const SizedBox(width: 14),
              Text(
                amount.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: _decreaseAmount,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              IconButton(
                onPressed: _increaseAmount,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        if (amountError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              amountError!,
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
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
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
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black : Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
