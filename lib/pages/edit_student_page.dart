import 'package:applikasi_identitas/models/data_model.dart';
import 'package:applikasi_identitas/models/wilayah_model.dart';
import 'package:applikasi_identitas/pages/home_page.dart';
import 'package:applikasi_identitas/services/supabase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditStudentPage extends StatefulWidget {
  final int studentId; // ID siswa dari tabel Supabase
  final Data student; // Data siswa untuk prefill form


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
  final supabaseService = SupabaseService();

  // key form
  final _formKey = GlobalKey<FormState>();

  // loading state
  bool _loading = false;

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
  late Future<void> _initData;

  // daftar dusun (untuk suggestion)
  List<String> _dusunSuggestions = [];
 String? _selectedDusun;
  @override
  void initState() {
    super.initState();
    _initData = _loadStudentData();
    _fetchDusunList();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _agamaController.dispose();
    _jenisKelaminController.dispose();
    _ttlController.dispose();
    _noHpController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _rtRwController.dispose();
    _dusunController.dispose();
    _desaController.dispose();
    _kecamatanController.dispose();
    _kabupatenController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    _namaAyahController.dispose();
    _namaIbuController.dispose();
    _namaWaliController.dispose();
    _alamatOrtuController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    final res = await supabase
        .from('siswa')
        .select()
        .eq('id', widget.studentId)
        .single();

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

  // ✅ ambil wilayah berdasarkan dusun
  Future<void> _fetchWilayahByDusun(String dusun) async {
    setState(() => _loading = true);
    try {
      final res = await supabase
          .from('wilayah')
          .select('desa, kecamatan, kabupaten, provinsi, kode_pos')
          .eq('dusun', dusun)
          .maybeSingle();

      if (res != null) {
        setState(() {
          _desaController.text = res['desa'] ?? '';
          _kecamatanController.text = res['kecamatan'] ?? '';
          _kabupatenController.text = res['kabupaten'] ?? '';
          _provinsiController.text = res['provinsi'] ?? '';
          _kodePosController.text = res['kode_pos'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal ambil data wilayah: $e")),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Ambil daftar dusun
  Future<void> _fetchDusunList() async {
    try {
      final res = await supabase.from('wilayah').select('dusun');
      setState(() {
        _dusunSuggestions =
            res.map<String>((e) => e['dusun'] as String).toList();
      });
    } catch (e) {
      debugPrint("Gagal ambil daftar dusun: $e");
    }
  }

   Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }



Future<void> _saveEdit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  bool online = await _hasInternet();
  if (!online) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tidak ada koneksi internet!")),
    );
    setState(() => _loading = false);
    return;
  }

  final supabase = Supabase.instance.client;

  try {
    // ===== Ambil ID wilayah berdasarkan dusun =====
    final dusunInput = _selectedDusun ?? _dusunController.text;
    if (dusunInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih dusun/wilayah terlebih dahulu")),
      );
      setState(() => _loading = false);
      return;
    }

    final wilayahDataRaw = await supabase
        .from('wilayah')
        .select('id')
        .eq('dusun', dusunInput)
        .maybeSingle();

    if (wilayahDataRaw == null || wilayahDataRaw['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendapatkan ID wilayah!")),
      );
      setState(() => _loading = false);
      return;
    }

    final wilayahId = wilayahDataRaw['id'] as int;

    // =====Update data siswa =====
    final siswaData = {
      'nama_lengkap': _namaController.text,
      'nisn': _nisController.text,
      'agama': _agamaController.text,
      'jenis_kelamin': _jenisKelaminController.text,
      'tempat_tanggal_lahir': _ttlController.text,
      'no_telp': _noHpController.text,
      'nik': _nikController.text,
      'alamat_jalan': _alamatController.text,
      'rt_rw': _rtRwController.text,
      'wilayah_id': wilayahId,
    };

    final siswaResponse = await supabase
        .from('siswa')
        .update(siswaData)
        .eq('id', widget.studentId)
        .select()
        .maybeSingle();

    if (siswaResponse == null || siswaResponse['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Gagal update siswa!")),
      );
      setState(() => _loading = false);
      return;
    }

    final siswaId = siswaResponse['id'] as int;

    // ===== Update data orang tua =====
    final orangTuaData = {
      'nama_ayah': _namaAyahController.text,
      'nama_ibu': _namaIbuController.text,
      'nama_wali': _namaWaliController.text,
      'alamat': _alamatOrtuController.text,
    };

    final orangTuaResponse = await supabase
        .from('orang_tua')
        .update(orangTuaData)
        .eq('siswa_id', siswaId)
        .select()
        .maybeSingle();

    if (orangTuaResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Gagal update orang tua!")),
      );
      setState(() => _loading = false);
      return;
    }

    // =====  Update object Data untuk UI =====
    final newData = Data(
      id: siswaId,
      namaLengkap: _namaController.text,
      nisn: _nisController.text,
      agama: _agamaController.text,
      jenisKelamin: _jenisKelaminController.text,
      tempatTanggalLahir: _ttlController.text,
      noHp: _noHpController.text,
      nik: _nikController.text,
      alamatJalan: _alamatController.text,
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
      provinsiId: null, // optional
    );

    Navigator.pop(context, newData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Data berhasil diupdate!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Gagal update: $e")),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (val) =>
            val == null || val.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 245, 249, 255),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
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
                            MaterialPageRoute(
                                builder: (_) => const HomePage()),
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Stepper
                Expanded(
                  child: Stepper(
                    currentStep: _currentStep,
                    onStepContinue: () async {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        await _saveEdit();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    steps: [
                      // Step Identitas
                      Step(
                        title: const Text("Identitas"),
                        content: Column(
                          children: [
                            _buildTextField("Nama Lengkap", _namaController),
                            _buildTextField("NISN", _nisController),
                            _buildTextField("Agama", _agamaController),
                            _buildTextField(
                                "Jenis Kelamin", _jenisKelaminController),
                            _buildTextField(
                                "Tempat, Tanggal Lahir", _ttlController),
                            _buildTextField("No HP", _noHpController),
                            _buildTextField("NIK", _nikController),
                          ],
                        ),
                        isActive: _currentStep >= 0,
                      ),

                      // Step Alamat
                      Step(
                        title: const Text("Alamat"),
                        content: Column(
                          children: [
                            _buildTextField("Alamat Jalan", _alamatController,
                                maxLines: 2),
                            _buildTextField("RT/RW", _rtRwController),

                            // Dusun pakai Autocomplete
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue value) {
                                  if (value.text.isEmpty) {
                                    return _dusunSuggestions;
                                  }
                                  return _dusunSuggestions.where((dusun) => dusun
                                      .toLowerCase()
                                      .contains(value.text.toLowerCase()));
                                },
                                onSelected: (val) async {
                                  _dusunController.text = val;
                                  await _fetchWilayahByDusun(val);
                                },
                                fieldViewBuilder: (context, controller,
                                    focusNode, onEditingComplete) {
                                  controller.text = _dusunController.text;
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    onEditingComplete: onEditingComplete,
                                    decoration: InputDecoration(
                                      labelText: "Dusun",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Tambahkan form otomatis
                            _buildTextField("Desa", _desaController,
                                readOnly: true),
                            _buildTextField("Kecamatan", _kecamatanController,
                                readOnly: true),
                            _buildTextField("Kabupaten", _kabupatenController,
                                readOnly: true),
                            _buildTextField("Provinsi", _provinsiController),

                            _buildTextField("Kode Pos", _kodePosController,
                                readOnly: true),
                          ],
                        ),
                        isActive: _currentStep >= 1,
                      ),

                      // Step Orang Tua
                      Step(
                        title: const Text("Orang Tua / Wali"),
                        content: Column(
                          children: [
                            _buildTextField("Nama Ayah", _namaAyahController),
                            _buildTextField("Nama Ibu", _namaIbuController),
                            _buildTextField("Nama Wali", _namaWaliController),
                            _buildTextField("Alamat Orang Tua", _alamatOrtuController, maxLines: 2),
                            // const SizedBox(height: 20),
                            // ElevatedButton(
                            //   onPressed: _loading ? null : _saveEdit,
                            //   style: ElevatedButton.styleFrom(
                            //     padding:
                            //         const EdgeInsets.symmetric(vertical: 16),
                            //   ),
                            //   child: _loading
                            //       ? const SizedBox(
                            //           height: 20,
                            //           width: 20,
                            //           child: CircularProgressIndicator(
                            //               strokeWidth: 2,
                            //               color: Colors.white),
                            //         )
                            //       : const Text("Simpan"),
                            // ),
                          ],
                        ),
                        isActive: _currentStep >= 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
