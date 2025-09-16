import 'package:applikasi_identitas/models/data_model.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalLahir = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final data = Data(
        nisn: _controllers['nisn']!.text,
        namaLengkap: _controllers['namaLengkap']!.text,
        jenisKelamin: _jenisKelamin ?? '',
        agama: _agama ?? '',
        tempatTanggalLahir:
            _tanggalLahir != null ? _tanggalLahir!.toIso8601String() : '',
        noHp: _controllers['noHp']!.text,
        nik: _controllers['nik']!.text,
        alamatJalan: _controllers['alamatJalan']!.text,
        rtRw: _controllers['rtRw']!.text,
        dusun: _controllers['dusun']!.text,
        desa: _controllers['desa']!.text,
        kecamatan: _controllers['kecamatan']!.text,
        kabupaten: _controllers['kabupaten']!.text,
        provinsi: _controllers['provinsi']!.text,
        kodePos: _controllers['kodePos']!.text,
        namaAyah: _controllers['namaAyah']!.text,
        namaIbu: _controllers['namaIbu']!.text,
        namaWali: _controllers['namaWali']!.text,
        alamatOrangTua: _controllers['alamatOrangTua']!.text,
      );

      Navigator.pop(context, data);
    }
  }

  Widget buildField(String key, {String? hint, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: key,
          hintText: hint,
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
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // putih bersih
      body: Column(
        children: [
          // Header
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

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep += 1);
                  } else {
                    _save();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  } else {
                    Navigator.pop(context);
                  }
                },
                steps: [
                  Step(
                    title: const Text("Data Diri"),
                    isActive: _currentStep >= 0,
                    content: Column(
                      children: [
                        buildField("nisn"),
                        buildField("namaLengkap"),
                        buildDropdown(
                          label: "Jenis Kelamin",
                          value: _jenisKelamin,
                          items: ["Laki-laki", "Perempuan"],
                          onChanged: (v) => setState(() => _jenisKelamin = v),
                        ),
                        buildDropdown(
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
                        buildField("noHp", keyboard: TextInputType.phone),
                        buildField("nik"),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text("Alamat"),
                    isActive: _currentStep >= 1,
                    content: Column(
                      children: [
                        buildField("alamatJalan"),
                        Row(
                          children: [
                            Expanded(child: buildField("rtRw")),
                            const SizedBox(width: 12),
                            Expanded(child: buildField("dusun")),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: buildField("desa")),
                            const SizedBox(width: 12),
                            Expanded(child: buildField("kecamatan")),
                          ],
                        ),
                        buildField("kabupaten"),
                        Row(
                          children: [
                            Expanded(child: buildField("provinsi")),
                            const SizedBox(width: 12),
                            Expanded(child: buildField("kodePos")),
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
                        buildField("namaAyah"),
                        buildField("namaIbu"),
                        buildField("namaWali"),
                        buildField("alamatOrangTua"),
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
                        )
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
