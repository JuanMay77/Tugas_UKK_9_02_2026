import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_petugas_page.dart';
import 'package:flutter_application_1/pages/petugas/loan_management_page.dart';
import 'package:flutter_application_1/pages/petugas/profile_petugas_page.dart';
import 'package:flutter_application_1/pages/petugas/return_management_page.dart';
import '../../core/constants/app_colors.dart';

class PetugasMainPage extends StatefulWidget {
  const PetugasMainPage({super.key});

  @override
  State<PetugasMainPage> createState() => _PetugasMainPageState();
}

class _PetugasMainPageState extends State<PetugasMainPage> {
  int _currentIndex = 0;

  final _pages = [
    DashboardPetugasPage(),
    LoanManagementPage(),
    ReturnManagementPage(),
    ProfilePetugasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.assignment),
            label: 'Loan Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Return Management',
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
