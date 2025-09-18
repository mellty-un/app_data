import 'package:applikasi_identitas/models/data_model.dart';
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

  /// ✅ Converter dari Data (Supabase) ke Student
  factory Student.fromData(Data data) {
    return Student(
      nisn: data.nisn,
      namaLengkap: data.namaLengkap,
      tempatTanggalLahir: data.tempatTanggalLahir,
      agama: data.agama,
      jenisKelamin: data.jenisKelamin,
      noHp: data.noHp,
      nik: data.nik,
      alamatJalan: data.alamatJalan,
      rtRw: data.rtRw,
      dusun: data.dusun,
      desa: data.desa,
      kecamatan: data.kecamatan,
      kabupaten: data.kabupaten,
      kodePos: data.kodePos,
      provinsi: data.provinsi,
      namaAyah: data.namaAyah,
      namaIbu: data.namaIbu,
      namaWali: data.namaWali,
      alamatOrangTua: data.alamatOrangTua,
    );
  }
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

Widget _buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(
   gradient: LinearGradient(
  colors: [Color(0xFF2196F3), Color(0xFF6A5ACD)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),


    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
  ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      student.namaLengkap, 
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // biar seimbang dengan IconButton
              ],
            ),
          ),

          // ✅ Isi detail
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  _buildSection("Alamat", [
                    _buildRow("Dusun", student.dusun),
                    _buildRow("Desa", student.desa),
                    _buildRow("Kecamatan", student.kecamatan),
                    _buildRow("Kabupaten", student.kabupaten),
                    _buildRow("Kode Pos", student.kodePos),
                    _buildRow("Provinsi", student.provinsi),
                  ]),
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
        ],
      ),
    );
  }
}
