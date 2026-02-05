import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat_model.dart';

class AlatService {
  static final _supabase = Supabase.instance.client;

  // GET ALL ALAT
  static Future<List<Alat>> getAllAlat() async {
    final response  = await _supabase
        .from('alat')
        .select();

    return (response as List)
        .map((e) => Alat.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET IMAGE
  static String getAlatImageUrl(String fileName) {
    return _supabase.storage
        .from('products')        
        .getPublicUrl(fileName);
  }
}
