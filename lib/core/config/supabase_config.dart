import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const supabaseUrl = 'https://wciinaxlqwbnbxvypabe.supabase.co';
  static const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjaWluYXhscXdibmJ4dnlwYWJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1OTA2NDUsImV4cCI6MjA4NDE2NjY0NX0.OXKktGTqAwIgGS03SzFpv52UY2FWXhxUbcR-HC2bAKc';

  static SupabaseClient get client => Supabase.instance.client;
}
