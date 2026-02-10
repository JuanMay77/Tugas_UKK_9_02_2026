import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DataProductPage extends StatelessWidget {
  const DataProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Data'),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'Alat'),
              Tab(icon: Icon(Icons.category), text: 'Kategori'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Manajemen Alat')),
            Center(child: Text('Manajemen Kategori')),
          ],
        ),
      ),
    );
  }
}
