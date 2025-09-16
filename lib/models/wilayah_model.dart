class Wilayah {
  final int id;
  final String kabupaten;
  final String kecamatan;
  final String desa;
  final String dusun;
  final String kodePos;

  Wilayah({
    required this.id,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
    required this.dusun,
    required this.kodePos,
  });

  factory Wilayah.fromJson(Map<String, dynamic> json) => Wilayah(
        id: json['id'],
        kabupaten: json['kabupaten'],
        kecamatan: json['kecamatan'],
        desa: json['desa'],
        dusun: json['dusun'],
        kodePos: json['kode_pos'],
      );
}
