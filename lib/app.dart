import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/dashboard_admin_page.dart';
import 'pages/dashboard/dashboard_petugas_page.dart';
import 'pages/dashboard/dashboard_peminjam_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const LoginPage(),
        '/dashboard-admin': (_) => const DashboardAdminPage(),
        '/dashboard-petugas': (_) => const DashboardPetugasPage(),
        '/dashboard-peminjam': (_) => const DashboardPeminjamPage(),
      },
    );
  }
}
