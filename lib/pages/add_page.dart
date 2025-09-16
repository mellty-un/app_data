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
      'alamatJalan','rtRw','dusun','desa','kecamatan','kabupaten','kodePos',
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

    final data = await supabase
        .from('wilayah')
        .select('desa, kecamatan, kabupaten, kode_pos')
        .eq('dusun', dusun)
        .maybeSingle();

    if (data != null) {
      setState(() {
        _controllers['desa']!.text = data['desa'] ?? '';
        _controllers['kecamatan']!.text = data['kecamatan'] ?? '';
        _controllers['kabupaten']!.text = data['kabupaten'] ?? '';
        _controllers['kodePos']!.text = data['kode_pos'] ?? '';
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

    bool online = await _hasInternet();
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada koneksi internet!")),
      );
      return;
    }

    final wilayah = Wilayah(
      id: 0,
      kabupaten: _controllers['kabupaten']!.text,
      kecamatan: _controllers['kecamatan']!.text,
      desa: _controllers['desa']!.text,
      dusun: _selectedDusun ?? _dusunController.text,
      kodePos: _controllers['kodePos']!.text,
    );

    final error = await supabaseService.createWilayah(wilayah);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal koneksi Supabase: $error")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan!")),
      );
      Navigator.pop(context, wilayah);
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
            child: const Center(
              child: Text(
                " Input Data",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
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
                  Step(
                    title: const Text("Data Diri"),
                    isActive: _currentStep >= 0,
                    content: Column(
                      children: [
                        CustomTextField(
                          controller: _controllers['nisn']!,
                          label: "NISN",
                        ),
                        CustomTextField(
                          controller: _controllers['namaLengkap']!,
                          label: "Nama Lengkap",
                        ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                        CustomTextField(
                          controller: _controllers['noHp']!,
                          label: "No HP",
                          keyboardType: TextInputType.phone,
                        ),
                        CustomTextField(
                          controller: _controllers['nik']!,
                          label: "NIK",
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text("Alamat"),
                    isActive: _currentStep >= 1,
                    content: Column(
                      children: [
                        CustomTextField(
                          controller: _controllers['alamatJalan']!,
                          label: "Alamat Jalan",
                          icon: Icons.home,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _controllers['rtRw']!,
                                label: "RT/RW",
                                icon: Icons.format_list_numbered,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                            Expanded(
                              child: CustomTextField(
                                controller: _controllers['desa']!,
                                label: "Desa",
                                icon: Icons.map,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _controllers['kecamatan']!,
                                label: "Kecamatan",
                                icon: Icons.map_outlined,
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          controller: _controllers['kabupaten']!,
                          label: "Kabupaten",
                          icon: Icons.location_on,
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _controllers['kodePos']!,
                                label: "Kode Pos",
                                icon: Icons.markunread_mailbox,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),


                  Step(
                    title: const Text("Orang Tua"),
                    isActive: _currentStep >= 2,
                    content: Column(
                      children: [
                        CustomTextField(
                          controller: _controllers['namaAyah']!,
                          label: "Nama Ayah",
                        ),
                        CustomTextField(
                          controller: _controllers['namaIbu']!,
                          label: "Nama Ibu",
                        ),
                        CustomTextField(
                          controller: _controllers['namaWali']!,
                          label: "Nama Wali",
                        ),
                        CustomTextField(
                          controller: _controllers['alamatOrangTua']!,
                          label: "Alamat Orang Tua",
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save),
                          label: const Text("Simpan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
