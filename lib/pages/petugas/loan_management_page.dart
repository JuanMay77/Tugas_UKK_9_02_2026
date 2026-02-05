import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanManagementPage extends StatefulWidget {
  const LoanManagementPage({super.key});

  @override
  State<LoanManagementPage> createState() => _DetailReturnPageState();
}

class _DetailReturnPageState extends State<LoanManagementPage> {
  final supabase = Supabase.instance.client;

  final overdueController = TextEditingController(text: '0');
  final feeController = TextEditingController(text: '0');

  String condition = 'Good';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _inputField('Overdue', overdueController),
                    _inputField('Fee', feeController),

                    // DROPDOWN KONDISI
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Condition'),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: condition,
                      items: const [
                        DropdownMenuItem(value: 'Good', child: Text('Good')),
                        DropdownMenuItem(value: 'Damaged', child: Text('Damaged')),
                        DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                      ],
                      onChanged: (val) => setState(() => condition = val!),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Detail Return',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
