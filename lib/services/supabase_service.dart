import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/wilayah_model.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<String?> createWilayah(Wilayah wilayah) async {
  if (!await _hasInternet()) return "Tidak ada koneksi internet";

  try {
    await supabase.from('wilayah').insert({
      'kabupaten': wilayah.kabupaten,
      'kecamatan': wilayah.kecamatan,
      'desa': wilayah.desa,
      'dusun': wilayah.dusun,
      'kode_pos': wilayah.kodePos,
    });
    return null;
  } catch (e) {
    return "Gagal koneksi Supabase: $e";
  }
}

Future<String?> updateWilayah(Wilayah wilayah) async {
  if (!await _hasInternet()) return "Tidak ada koneksi internet";

  try {
    await supabase.from('wilayah').update({
      'kabupaten': wilayah.kabupaten,
      'kecamatan': wilayah.kecamatan,
      'desa': wilayah.desa,
      'dusun': wilayah.dusun,
      'kode_pos': wilayah.kodePos,
    }).eq('id', wilayah.id);
    return null;
  } catch (e) {
    return "Gagal koneksi Supabase: $e";
  }
}


  Future<String?> deleteWilayah(int id) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";

    try {
      await supabase.from('wilayah').delete().eq('id', id);
      return null;
    } catch (e) {
      return "Gagal koneksi Supabase: $e";
    }
  }

  /// Ambil semua nama dusun (unik)
  Future<List<String>> getDusuns() async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");

    try {
      final data = await supabase.from('wilayah').select('dusun') as List<dynamic>? ?? [];
      final dusuns = data.map((e) => e['dusun'].toString()).toSet().toList();
      return dusuns;
    } catch (e) {
      throw Exception("Gagal koneksi Supabase: $e");
    }
  }

  Future<Map<String, dynamic>?> getWilayahByDusun(String dusun) async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");

    try {
      final data = await supabase
          .from('wilayah')
          .select()
          .eq('dusun', dusun)
          .maybeSingle(); 

      return data;
    } catch (e) {
      throw Exception("Gagal koneksi Supabase: $e");
    }
  }
}
