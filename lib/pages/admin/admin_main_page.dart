import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/petugas_management_page.dart';
import 'package:flutter_application_1/pages/admin/product_management_page.dart';
import 'package:flutter_application_1/pages/admin/profile_admin_page.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_admin_page.dart';
import '../../core/constants/app_colors.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  final _pages = [
    DashboardAdminPage(),
    DataProductPage(),
    PetugasManagementPage(),
    ProfileAdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Data Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: 'Petugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
