import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_peminjam_page.dart';
import 'history_page.dart';
import 'return_page.dart';
import 'profile_page.dart';
import '../../core/constants/app_colors.dart';

class PeminjamMainPage extends StatefulWidget {
  const PeminjamMainPage({super.key});

  @override
  State<PeminjamMainPage> createState() => _PeminjamMainPageState();
}

class _PeminjamMainPageState extends State<PeminjamMainPage> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardPeminjamPage(),
    HistoryPage(),
    ReturnPage(),
    ProfilePage(),
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
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Return',
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
