import 'package:flutter/material.dart';
import '../models/data_model.dart';

class EditStudentPage extends StatefulWidget {
  final Data student;

  const EditStudentPage({super.key, required this.student});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  // Controller untuk semua field
  late TextEditingController _namaController;
  late TextEditingController _nisController;
  late TextEditingController _agamaController;
  late TextEditingController _alamatController;
  late TextEditingController _jenisKelaminController;
  late TextEditingController _ttlController;
  late TextEditingController _noHpController;
  late TextEditingController _nikController;
  late TextEditingController _rtRwController;
  late TextEditingController _dusunController;
  late TextEditingController _desaController;
  late TextEditingController _kecamatanController;
  late TextEditingController _kabupatenController;
  late TextEditingController _provinsiController;
  late TextEditingController _kodePosController;
  late TextEditingController _namaAyahController;
  late TextEditingController _namaIbuController;
  late TextEditingController _namaWaliController;
  late TextEditingController _alamatOrtuController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.student.namaLengkap);
    _nisController = TextEditingController(text: widget.student.nisn);
    _agamaController = TextEditingController(text: widget.student.agama);
    _alamatController = TextEditingController(text: widget.student.alamatJalan);
    _jenisKelaminController = TextEditingController(text: widget.student.jenisKelamin);
    _ttlController = TextEditingController(text: widget.student.tempatTanggalLahir);
    _noHpController = TextEditingController(text: widget.student.noHp);
    _nikController = TextEditingController(text: widget.student.nik);
    _rtRwController = TextEditingController(text: widget.student.rtRw);
    _dusunController = TextEditingController(text: widget.student.dusun);
    _desaController = TextEditingController(text: widget.student.desa);
    _kecamatanController = TextEditingController(text: widget.student.kecamatan);
    _kabupatenController = TextEditingController(text: widget.student.kabupaten);
    _provinsiController = TextEditingController(text: widget.student.provinsi);
    _kodePosController = TextEditingController(text: widget.student.kodePos);
    _namaAyahController = TextEditingController(text: widget.student.namaAyah);
    _namaIbuController = TextEditingController(text: widget.student.namaIbu);
    _namaWaliController = TextEditingController(text: widget.student.namaWali);
    _alamatOrtuController = TextEditingController(text: widget.student.alamatOrangTua);
  }

  void _saveEdit() {
    final updatedStudent = Data(
      namaLengkap: _namaController.text,
      nisn: _nisController.text,
      agama: _agamaController.text,
      alamatJalan: _alamatController.text,
      jenisKelamin: _jenisKelaminController.text,
      tempatTanggalLahir: _ttlController.text,
      noHp: _noHpController.text,
      nik: _nikController.text,
      rtRw: _rtRwController.text,
      dusun: _dusunController.text,
      desa: _desaController.text,
      kecamatan: _kecamatanController.text,
      kabupaten: _kabupatenController.text,
      provinsi: _provinsiController.text,
      kodePos: _kodePosController.text,
      namaAyah: _namaAyahController.text,
      namaIbu: _namaIbuController.text,
      namaWali: _namaWaliController.text,
      alamatOrangTua: _alamatOrtuController.text,
    );
    Navigator.pop(context, updatedStudent);
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 249, 255),
      body: Column(
        children: [
          // Custom Header pakai Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 7, 112, 217),
                  Color.fromARGB(255, 22, 56, 107),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Text(
                "Edit Data Siswa",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Form input
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField("Nama Lengkap", _namaController),
                  _buildTextField("NISN", _nisController),
                  _buildTextField("Agama", _agamaController),
                  _buildTextField("Alamat", _alamatController, maxLines: 2),
                  _buildTextField("Jenis Kelamin", _jenisKelaminController),
                  _buildTextField("Tempat, Tanggal Lahir", _ttlController),
                  _buildTextField("No HP", _noHpController),
                  _buildTextField("NIK", _nikController),
                  _buildTextField("RT/RW", _rtRwController),
                  _buildTextField("Dusun", _dusunController),
                  _buildTextField("Desa", _desaController),
                  _buildTextField("Kecamatan", _kecamatanController),
                  _buildTextField("Kabupaten", _kabupatenController),
                  _buildTextField("Provinsi", _provinsiController),
                  _buildTextField("Kode Pos", _kodePosController),
                  _buildTextField("Nama Ayah", _namaAyahController),
                  _buildTextField("Nama Ibu", _namaIbuController),
                  _buildTextField("Nama Wali", _namaWaliController),
                  _buildTextField("Alamat Orang Tua", _alamatOrtuController, maxLines: 2),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
