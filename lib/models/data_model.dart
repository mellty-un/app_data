class Data {
  final int id; 
  final int? wilayahId;
  final int? orangTuaId;// ID siswa
  final String namaLengkap;
  final String nisn;
  final String agama;
  final String jenisKelamin;
  final String tempatTanggalLahir;
  final String noHp;
  final String nik;
  final String alamatJalan;
  final String rtRw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final int? provinsiId; 
  final String provinsi;
  final String kodePos;
  final String namaAyah;
  final String namaIbu;
  final String namaWali;
  final String alamatOrangTua;

  Data({
    required this.id,
    required this.namaLengkap,
    required this.nisn,
    this.wilayahId,
    this.orangTuaId,
    required this.agama,
    required this.jenisKelamin,
    required this.tempatTanggalLahir,
    required this.noHp,
    required this.nik,
    required this.alamatJalan,
    required this.rtRw,
    required this.dusun,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    this.provinsiId, // optional
    required this.provinsi,
    required this.kodePos,
    required this.namaAyah,
    required this.namaIbu,
    required this.namaWali,
    required this.alamatOrangTua,
  });

  // Mapping dari Supabase
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] as int,
      namaLengkap: json['nama_lengkap'] ?? '',
      nisn: json['nisn'] ?? '',
      agama: json['agama'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tempatTanggalLahir: json['tempat_tanggal_lahir'] ?? '',
      noHp: json['no_hp'] ?? '',
      nik: json['nik'] ?? '',
      alamatJalan: json['alamat_jalan'] ?? '',
      rtRw: json['rt_rw'] ?? '',
      dusun: json['dusun'] ?? '',
      desa: json['desa'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      provinsiId: json['id'] != null ? json['id'] as int : null, 
      provinsi: json['provinsi'] ?? '', 
      kodePos: json['kode_pos'] ?? '',
      namaAyah: json['nama_ayah'] ?? '',
      namaIbu: json['nama_ibu'] ?? '',
      namaWali: json['nama_wali'] ?? '',
      alamatOrangTua: json['alamat'] ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nisn': nisn,
      'agama': agama,
      'jenis_kelamin': jenisKelamin,
      'tempat_tanggal_lahir': tempatTanggalLahir,
      'no_hp': noHp,
      'nik': nik,
      'alamat_jalan': alamatJalan,
      'rt_rw': rtRw,
      'dusun': dusun,
      'desa': desa,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'id': provinsiId, 
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'nama_wali': namaWali,
      'alamat': alamatOrangTua,

    };
  }
}
