import 'package:applikasi_identitas/models/data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/wilayah_model.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ===== CEK KONEKSI INTERNET =====
  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// ===== WILAYAH =====
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
      await supabase
          .from('wilayah')
          .update({
            'kabupaten': wilayah.kabupaten,
            'kecamatan': wilayah.kecamatan,
            'desa': wilayah.desa,
            'dusun': wilayah.dusun,
            'kode_pos': wilayah.kodePos,
          })
          .eq('id', wilayah.id);
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

  Future<List<String>> getDusuns() async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");

    try {
      final data = await supabase.from('wilayah').select('dusun');
      final List<dynamic> list = (data is List) ? data : [];
      final dusuns = list.map((e) => e['dusun'].toString()).toSet().toList();
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
          .maybeSingle(); // ambil Map atau null
      return data as Map<String, dynamic>?;
    } catch (e) {
      throw Exception("Gagal koneksi Supabase: $e");
    }
  }

  /// ===== SISWA =====
  Future<String?> createStudent(Map<String, dynamic> data) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";
    try {
      await supabase.from('siswa').insert(data);
      return null;
    } catch (e) {
      return "Gagal koneksi Supabase: $e";
    }
  }

  // ✅ UPDATE SISWA
  Future<String?> updateStudent(int id, Map<String, dynamic> data) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";
    try {
      await supabase.from('siswa').update(data).eq('id', id);
      return null;
    } catch (e) {
      return "Gagal update siswa: $e";
    }
  }

  // ✅ DELETE SISWA
  Future<String?> deleteStudent(int id) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";
    try {
      await supabase.from('siswa').delete().eq('id', id);
      return null;
    } catch (e) {
      return "Gagal hapus siswa: $e";
    }
  }

  Future<List<Data>> getStudents() async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");

    try {
      final response = await supabase.from('siswa').select('''
      id,
      nisn,
      nama_lengkap,
      tempat_tanggal_lahir,
      agama,
      jenis_kelamin,
      no_telp,
      nik,
      alamat_jalan,
      rt_rw,
      orang_tua!orang_tua_siswa_id_fkey(
        nama_ayah,
        nama_ibu,
        nama_wali,
        alamat
      ),
      wilayah!siswa_wilayah_id_fkey(
      dusun,
      desa,
      kecamatan,
      kabupaten,
      provinsi,
      kode_pos
    )
    ''');

      if (response == null) return [];

      // Jika response Map → ubah jadi List supaya konsisten
      final dataList = (response is List) ? response : [response];

      return dataList.map((json) {
        final map = json as Map<String, dynamic>;

        final orangTuaRaw = map['orang_tua'];
        final Map<String, dynamic> orangTua;
        if (orangTuaRaw is List && orangTuaRaw.isNotEmpty) {
          orangTua = orangTuaRaw[0] as Map<String, dynamic>;
        } else if (orangTuaRaw is Map<String, dynamic>) {
          orangTua = orangTuaRaw;
        } else {
          orangTua = {};
        }

        final wilayahRaw = map['wilayah'];
        final Map<String, dynamic> wilayah;
        if (wilayahRaw is List && wilayahRaw.isNotEmpty) {
          wilayah = wilayahRaw[0] as Map<String, dynamic>;
        } else if (wilayahRaw is Map<String, dynamic>) {
          wilayah = wilayahRaw;
        } else {
          wilayah = {};
        }

        return Data(
          id: map['id'] as int? ?? 0,
          nisn: map['nisn'] ?? '',
          namaLengkap: map['nama_lengkap'] ?? '',
          tempatTanggalLahir: map['tempat_tanggal_lahir'] ?? '',
          agama: map['agama'] ?? '',
          jenisKelamin: map['jenis_kelamin'] ?? '',
          noHp: map['no_telp'] ?? '',
          nik: map['nik'] ?? '',
          alamatJalan: map['alamat_jalan'] ?? '',
          rtRw: map['rt_rw'] ?? '',
          dusun: wilayah['dusun'] ?? '',
          desa: wilayah['desa'] ?? '',
          kecamatan: wilayah['kecamatan'] ?? '',
          kabupaten: wilayah['kabupaten'] ?? '',
          kodePos: wilayah['kode_pos'] ?? '',
          provinsi: map['provinsi'] ?? '',
          namaAyah: orangTua['nama_ayah'] ?? '',
          namaIbu: orangTua['nama_ibu'] ?? '',
          namaWali: orangTua['nama_wali'] ?? '',
          alamatOrangTua: orangTua['alamat'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception("Gagal koneksi Supabase: $e");
    }
  }

  /// ===== ORANG TUA =====
  Future<String?> createOrangTua(Map<String, dynamic> data) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";
    try {
      await supabase.from('orang_tua').insert(data);
      return null;
    } catch (e) {
      return "Gagal koneksi Supabase: $e";
    }
  }

  Future<List<Map<String, dynamic>>> getOrangTua() async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");
    final data = await supabase.from('orang_tua').select();
    return List<Map<String, dynamic>>.from(data);
  }
  Future<String?> updateOrangTua(int siswaId, Map<String, dynamic> data) async {
  try {
    await supabase.from('orang_tua').update(data).eq('siswa_id', siswaId);
    return null;
  } catch (e) {
    return "Gagal update orang tua: $e";
  }
}


  /// ===== PROVINSI =====
  Future<List<Map<String, dynamic>>> getProvinsi() async {
    if (!await _hasInternet()) throw Exception("Tidak ada koneksi internet");
    final data = await supabase.from('provinsi').select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<String?> createProvinsi(String namaProvinsi) async {
    if (!await _hasInternet()) return "Tidak ada koneksi internet";
    try {
      await supabase.from('provinsi').insert({'nama_provinsi': namaProvinsi});
      return null;
    } catch (e) {
      return "Gagal koneksi Supabase: $e";
    }
  }
}
