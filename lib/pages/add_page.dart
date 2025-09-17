import 'package:applikasi_identitas/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/wilayah_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  int? _selectedWilayahId;
   Map<String, dynamic>? _selectedWilayah; 
  

  final Map<String, TextEditingController> _controllers = {};
  String? _jenisKelamin;
  String? _agama;
  DateTime? _tanggalLahir;

  final SupabaseService supabaseService = SupabaseService();

  // Autocomplete Dusun
  List<String> _dusunSuggestions = [];
  final TextEditingController _dusunController = TextEditingController();
  String? _selectedDusun;

  @override
  void initState() {
    super.initState();

    final fields = [
      'nisn','namaLengkap','noHp','nik',
      'alamatJalan','rtRw','dusun','desa','kecamatan','kabupaten','provinsi','kodePos',
      'namaAyah','namaIbu','namaWali','alamatOrangTua',
    ];

    for (var f in fields) {
      _controllers[f] = TextEditingController();
    }

    fetchDusuns();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    _dusunController.dispose();
    super.dispose();
  }

  Future<void> fetchDusuns() async {
    try {
      bool online = await _hasInternet();
      if (!online) return;

      final dusuns = await supabaseService.getDusuns();
      setState(() => _dusunSuggestions = dusuns);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data dusun: $e")),
      );
    }
  }

  Future<void> _fetchWilayahByDusun(String dusun) async {
  try {
    final supabase = Supabase.instance.client;

    final res = await supabase
        .from('wilayah')
        .select('desa, kecamatan, kabupaten, provinsi, kode_pos')
        .eq('dusun', dusun)
        .maybeSingle();

    if (res != null) {
      setState(() {
        _controllers['desa']!.text = res['desa'] ?? '';
        _controllers['kecamatan']!.text = res['kecamatan'] ?? '';
        _controllers['kabupaten']!.text = res['kabupaten'] ?? '';
        _controllers['provinsi']!.text = res['provinsi'] ?? ''; 
        _controllers['kodePos']!.text = res['kode_pos'] ?? '';
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal ambil data wilayah: $e")),
    );
  }
}


  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

void _save() async {
  if (!_formKey.currentState!.validate()) return;

  // ✅ Pastikan ada koneksi internet
  bool online = await _hasInternet();
  if (!online) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tidak ada koneksi internet!")),
    );
    return;
  }

  // ✅ Pastikan user sudah pilih dusun/wilayah
  final dusunInput = _selectedDusun ?? _dusunController.text;
  if (dusunInput.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Harap pilih dusun/wilayah terlebih dahulu")),
    );
    return;
  }

  final supabase = Supabase.instance.client;

  // ✅ Ambil ID wilayah
  if (_selectedWilayahId == null) {
    final wilayahData = await supabase
        .from('wilayah')
        .select('id')
        .eq('dusun', dusunInput)
        .maybeSingle();

    if (wilayahData == null || wilayahData['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendapatkan ID wilayah!")),
      );
      return;
    }

    _selectedWilayahId = wilayahData['id'] as int;
  }

  try {
    // 1️⃣ Simpan data siswa
    final studentData = {
      'nisn': _controllers['nisn']!.text,
      'nama_lengkap': _controllers['namaLengkap']!.text,
      'agama': _agama ?? '',
      'jenis_kelamin': _jenisKelamin ?? '',
      'tempat_tanggal_lahir': _tanggalLahir != null
          ? "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}"
          : '',
      'no_telp': _controllers['noHp']!.text,
      'nik': _controllers['nik']!.text,
      'alamat_jalan': _controllers['alamatJalan']!.text,
      'rt_rw': _controllers['rtRw']!.text,
      'wilayah_id': _selectedWilayahId, // FK ke wilayah
    };

    final studentResponse = await supabase
        .from('siswa')
        .insert(studentData)
        .select()
        .maybeSingle();

    if (studentResponse == null || studentResponse['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Gagal menyimpan siswa!")),
      );
      return;
    }

    final siswaId = studentResponse['id'] as int;

    // 2️⃣ Simpan orang tua
    final orangTuaData = {
      'siswa_id': siswaId,
      'nama_ayah': _controllers['namaAyah']!.text,
      'nama_ibu': _controllers['namaIbu']!.text,
      'nama_wali': _controllers['namaWali']!.text,
      'alamat': _controllers['alamatOrangTua']!.text,
    };

    final orangTuaResponse = await supabase
        .from('orang_tua')
        .insert(orangTuaData)
        .select()
        .maybeSingle();

    if (orangTuaResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Gagal menyimpan orang tua!")),
      );
      return;
    }

    // ✅ Berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Data berhasil disimpan!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  decoration: const BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Center(
        child: Text(
          "Input Data",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      Positioned(
        left: 0,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
    ],
  ),
),

        Expanded(
  child: Form(
    key: _formKey,
    child: Stepper(
      type: StepperType.horizontal,
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 2) setState(() => _currentStep += 1);
        else _save();
      },
      onStepCancel: () {
        if (_currentStep > 0) setState(() => _currentStep -= 1);
        else Navigator.pop(context);
      },
      steps: [
        // ===== STEP DATA DIRI =====
        Step(
          title: const Text("Data Diri"),
          isActive: _currentStep >= 0,
          content: Column(
            children: [
              CustomTextField(controller: _controllers['nisn']!, label: "NISN"),
              CustomTextField(controller: _controllers['namaLengkap']!, label: "Nama Lengkap"),
              CustomDropdownField(
                label: "Jenis Kelamin",
                value: _jenisKelamin,
                items: ["Laki-laki", "Perempuan"],
                onChanged: (v) => setState(() => _jenisKelamin = v),
              ),
              CustomDropdownField(
                label: "Agama",
                value: _agama,
                items: ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"],
                onChanged: (v) => setState(() => _agama = v),
              ),
              InkWell(
                onTap: _pickTanggalLahir,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Tanggal Lahir",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Text(
                    _tanggalLahir != null
                        ? "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}"
                        : "Pilih tanggal",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              CustomTextField(controller: _controllers['noHp']!, label: "No HP", keyboardType: TextInputType.phone),
              CustomTextField(controller: _controllers['nik']!, label: "NIK"),
            ],
          ),
        ),

        // ===== STEP ALAMAT =====
        Step(
          title: const Text("Alamat"),
          isActive: _currentStep >= 1,
          content: Column(
            children: [
              CustomTextField(controller: _controllers['alamatJalan']!, label: "Alamat Jalan", icon: Icons.home),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(controller: _controllers['rtRw']!, label: "RT/RW", icon: Icons.format_list_numbered),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                        return _dusunSuggestions.where((dusun) =>
                            dusun.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        _dusunController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Dusun",
                            prefixIcon: const Icon(Icons.location_city),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                          onEditingComplete: onEditingComplete,
                        );
                      },
                      onSelected: (value) {
                        setState(() {
                          _selectedDusun = value;
                          _dusunController.text = value;
                        });
                        _fetchWilayahByDusun(value);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: _controllers['desa']!, label: "Desa", icon: Icons.map)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomTextField(controller: _controllers['kecamatan']!, label: "Kecamatan", icon: Icons.map_outlined)),
                ],
              ),
              CustomTextField(controller: _controllers['kabupaten']!, label: "Kabupaten", icon: Icons.location_on),
              CustomTextField(controller: _controllers['provinsi']!, label: "Provinsi", icon: Icons.public),
              CustomTextField(controller: _controllers['kodePos']!, label: "Kode Pos", icon: Icons.markunread_mailbox),
            ],
          ),
        ),

        // ===== STEP ORANG TUA =====
        Step(
          title: const Text("Orang Tua"),
          isActive: _currentStep >= 2,
          content: Column(
            children: [
              CustomTextField(controller: _controllers['namaAyah']!, label: "Nama Ayah"),
              CustomTextField(controller: _controllers['namaIbu']!, label: "Nama Ibu"),
              CustomTextField(controller: _controllers['namaWali']!, label: "Nama Wali"),
              CustomTextField(controller: _controllers['alamatOrangTua']!, label: "Alamat Orang Tua"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Simpan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)

                ],
              ),

            );
         
  }
}
