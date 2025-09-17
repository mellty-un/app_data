import 'package:applikasi_identitas/models/data_model.dart';
import 'package:applikasi_identitas/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditStudentPage extends StatefulWidget {
  final int studentId; // ID siswa dari tabel Supabase
  final Data student;  // Data siswa untuk prefill form

  const EditStudentPage({
    super.key,
    required this.studentId,
    required this.student,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}



class _EditStudentPageState extends State<EditStudentPage> {
  final supabase = Supabase.instance.client;

  // controller identitas
  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _agamaController = TextEditingController();
  final _jenisKelaminController = TextEditingController();
  final _ttlController = TextEditingController();
  final _noHpController = TextEditingController();
  final _nikController = TextEditingController();

  // controller alamat
  final _alamatController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _dusunController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kodePosController = TextEditingController();

  // controller orang tua
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _namaWaliController = TextEditingController();
  final _alamatOrtuController = TextEditingController();

  int _currentStep = 0;

  Future<void> _loadStudentData() async {
    final res = await supabase.from('siswa').select().eq('id', widget.studentId).single();

    // isi semua controller dari data Supabase
    _namaController.text = res['nama_lengkap'] ?? '';
    _nisController.text = res['nisn'] ?? '';
    _agamaController.text = res['agama'] ?? '';
    _jenisKelaminController.text = res['jenis_kelamin'] ?? '';
    _ttlController.text = res['tempat_tanggal_lahir'] ?? '';
    _noHpController.text = res['no_hp'] ?? '';
    _nikController.text = res['nik'] ?? '';

    _alamatController.text = res['alamat_jalan'] ?? '';
    _rtRwController.text = res['rt_rw'] ?? '';
    _dusunController.text = res['dusun'] ?? '';
    _desaController.text = res['desa'] ?? '';
    _kecamatanController.text = res['kecamatan'] ?? '';
    _kabupatenController.text = res['kabupaten'] ?? '';
    _provinsiController.text = res['provinsi'] ?? '';
    _kodePosController.text = res['kode_pos'] ?? '';

    _namaAyahController.text = res['nama_ayah'] ?? '';
    _namaIbuController.text = res['nama_ibu'] ?? '';
    _namaWaliController.text = res['nama_wali'] ?? '';
    _alamatOrtuController.text = res['alamat_orang_tua'] ?? '';
  }

  Future<void> _onDusunSelected(String dusun) async {
    final res = await supabase.from('dusun').select().eq('nama_dusun', dusun).single();
    _desaController.text = res['desa'] ?? '';
    _kecamatanController.text = res['kecamatan'] ?? '';
    _kabupatenController.text = res['kabupaten'] ?? '';
    _kodePosController.text = res['kode_pos'] ?? '';
  }
Future<void> _saveEdit() async {
  final supabase = Supabase.instance.client;

  await supabase.from('siswa').update({
    'nama_lengkap': _namaController.text,
    'agama': _agamaController.text,
    'jenis_kelamin': _jenisKelaminController.text,
    'tempat_tanggal_lahir': _ttlController.text,
    'no_hp': _noHpController.text,
    'nik': _nikController.text,
    'alamat_jalan': _alamatController.text,
    'rt_rw': _rtRwController.text,
    'dusun': _dusunController.text,
    'desa': _desaController.text,
    'kecamatan': _kecamatanController.text,
    'kabupaten': _kabupatenController.text,
    'provinsi': _provinsiController.text,
    'kode_pos': _kodePosController.text,
    'nama_ayah': _namaAyahController.text,
    'nama_ibu': _namaIbuController.text,
    'nama_wali': _namaWaliController.text,
    'alamat_orang_tua': _alamatOrtuController.text,
  }).eq('nisn', widget.student.nisn); // ✅ pakai NISN sebagai key unik

  Navigator.pop(context, true); // kirim true biar home page refresh
}


  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
    return FutureBuilder(
      future: _loadStudentData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
return Scaffold(
  backgroundColor: const Color.fromARGB(255, 245, 249, 255),
  body: Column(
    children: [
      // HEADER
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0770D9), Color(0xFF16386B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Center(
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
            const SizedBox(width: 48), // supaya teks tetap center
          ],
        ),
      ),

      // Stepper
      Expanded(
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _saveEdit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            Step(
              title: const Text("Identitas"),
              content: Column(
                children: [
                  _buildTextField("Nama Lengkap", _namaController),
                  _buildTextField("NISN", _nisController),
                  _buildTextField("Agama", _agamaController),
                  _buildTextField("Jenis Kelamin", _jenisKelaminController),
                  _buildTextField("Tempat, Tanggal Lahir", _ttlController),
                  _buildTextField("No HP", _noHpController),
                  _buildTextField("NIK", _nikController),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text("Alamat"),
              content: Column(
                children: [
                  _buildTextField("Alamat Jalan", _alamatController, maxLines: 2),
                  _buildTextField("RT/RW", _rtRwController),

                  // Dusun pakai Autocomplete
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) async {
                        if (value.text.isEmpty) return [];
                        final res = await supabase
                            .from('dusun')
                            .select('nama_dusun')
                            .ilike('nama_dusun', '%${value.text}%');
                        return res.map<String>((e) => e['nama_dusun']).toList();
                      },
                      onSelected: (val) {
                        _dusunController.text = val;
                        _onDusunSelected(val);
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        controller.text = _dusunController.text;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Dusun",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _buildTextField("Desa", _desaController),
                  _buildTextField("Kecamatan", _kecamatanController),
                  _buildTextField("Kabupaten", _kabupatenController),
                  _buildTextField("Provinsi", _provinsiController),
                  _buildTextField("Kode Pos", _kodePosController),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text("Orang Tua / Wali"),
              content: Column(
                children: [
                  _buildTextField("Nama Ayah", _namaAyahController),
                  _buildTextField("Nama Ibu", _namaIbuController),
                  _buildTextField("Nama Wali", _namaWaliController),
                  _buildTextField("Alamat Orang Tua", _alamatOrtuController, maxLines: 2),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    ],
  ),
);
      });
  }
}


