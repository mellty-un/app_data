import 'package:flutter/material.dart';

class Student {
  final String nisn;
  final String namaLengkap;
  final String tempatTanggalLahir;
  final String agama;
  final String jenisKelamin;
  final String noHp;
  final String nik;
  final String alamatJalan;
  final String rtRw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String kodePos;
  final String provinsi;
  final String namaAyah;
  final String namaIbu;
  final String namaWali;
  final String alamatOrangTua;

  Student({
    required this.nisn,
    required this.namaLengkap,
    required this.tempatTanggalLahir,
    required this.agama,
    required this.jenisKelamin,
    required this.noHp,
    required this.nik,
    required this.alamatJalan,
    required this.rtRw,
    required this.dusun,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    required this.kodePos,
    required this.provinsi,
    required this.namaAyah,
    required this.namaIbu,
    required this.namaWali,
    required this.alamatOrangTua,
  });
}

class DetailPage extends StatelessWidget {
  final Student student;

  const DetailPage({super.key, required this.student});

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              )
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Siswa"),
        backgroundColor: const Color(0xFF0770D9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFEFF3F8),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Container 1: Data Diri
                _buildSection("Data Diri", [
                  _buildRow("NISN", student.nisn),
                  _buildRow("Nama Lengkap", student.namaLengkap),
                  _buildRow("Tempat/Tanggal Lahir", student.tempatTanggalLahir),
                  _buildRow("Agama", student.agama),
                  _buildRow("Jenis Kelamin", student.jenisKelamin),
                  _buildRow("No. HP", student.noHp),
                  _buildRow("NIK", student.nik),
                  _buildRow("Alamat Jalan", student.alamatJalan),
                  _buildRow("RT/RW", student.rtRw),
                ]),

                // Container 2: Alamat
                _buildSection("Alamat", [
                  _buildRow("Dusun", student.dusun),
                  _buildRow("Desa", student.desa),
                  _buildRow("Kecamatan", student.kecamatan),
                  _buildRow("Kabupaten", student.kabupaten),
                  _buildRow("Kode Pos", student.kodePos),
                  _buildRow("Provinsi", student.provinsi),
                ]),

                // Container 3: Orang Tua / Wali
                _buildSection("Orang Tua / Wali", [
                  _buildRow("Nama Ayah", student.namaAyah),
                  _buildRow("Nama Ibu", student.namaIbu),
                  _buildRow("Nama Wali", student.namaWali),
                  _buildRow("Alamat", student.alamatOrangTua),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
