import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_model.dart';
import 'add_page.dart';
import 'edit_student_page.dart';
import '../widgets/student_card.dart';
import '../services/supabase_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Data> _students = [];
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadStudents(); // load data dari SharedPreferences
  }

  // Load data siswa dari SharedPreferences
  Future<void> _loadStudents() async {
  try {
    final dataList = await _supabaseService.getStudents(); // sudah return List<Data>

    setState(() {
      _students = dataList; // langsung assign, karena sudah List<Data>
    });
  } catch (e) {
    print("Gagal load siswa: $e");
  }
}

  // Simpan data siswa ke SharedPreferences
  Future<void> _saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = _students.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('students', dataString);
  }

  // Tambah siswa baru
  void _addStudent() async {
    final newStudent = await Navigator.push<Data>(
      context,
      MaterialPageRoute(builder: (_) => const AddPage()),
    );

    if (newStudent != null) {
      setState(() {
        _students.add(newStudent);
      });
      _saveStudents(); // simpan data baru
    }
  }

  // Edit siswa
  void _editStudent(int index) async {
   final updatedStudent = await Navigator.push<Data>(
  context,
  MaterialPageRoute(
    builder: (_) => EditStudentPage(
      studentId: _students[index].id,
      student: _students[index],
      
    ),
  ),
);

if (updatedStudent != null) {
  setState(() {
    _students[index] = updatedStudent;
  });
}


  }

  // Hapus siswa
void _deleteStudent(int index) async {
  final student = _students[index];

  final confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // tidak bisa dismiss tap di luar
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              "Konfirmasi Hapus",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Apakah kamu yakin ingin menghapus siswa\n${student.namaLengkap}?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );

  if (confirm != true) return;

  final error = await SupabaseService.deleteStudentFull(student.id);
  if (error != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error)));
    return;
  }

  setState(() => _students.removeAt(index));

  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Siswa berhasil dihapus")));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
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
                  "Data Siswa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List siswa
            Expanded(
              child: _students.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada data siswa",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final s = _students[index];
                        return StudentCard(
  name: _students[index].namaLengkap,
  nis: _students[index].nisn,
 major: '-', 
  address: _students[index].alamatJalan,
  desa: _students[index].desa,
  kecamatan: _students[index].kecamatan,
  kabupaten: _students[index].kabupaten,
  provinsi: _students[index].provinsi,
  onEdit: () => _editStudent(index),
  onDelete: () => _deleteStudent(index),
);

                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
