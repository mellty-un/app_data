import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_model.dart';
import 'add_page.dart';
import 'edit_student_page.dart';
import '../widgets/student_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Data> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents(); 
  }

  Future<void> _loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getStringList('students') ?? [];
    setState(() {
      _students = dataString
          .map((s) => Data.fromJson(jsonDecode(s)))
          .toList();
    });
  }

  Future<void> _saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = _students.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('students', dataString);
  }

  void _addStudent() async {
    final newStudent = await Navigator.push<Data>(
      context,
      MaterialPageRoute(builder: (_) => const AddPage()),
    );

    if (newStudent != null) {
      setState(() {
        _students.add(newStudent);
      });
      _saveStudents(); 
    }
  }

  void _editStudent(int index) async {
    final updatedStudent = await Navigator.push<Data>(
      context,
      MaterialPageRoute(
        builder: (_) => EditStudentPage(student: _students[index]),
      ),
    );

    if (updatedStudent != null) {
      setState(() {
        _students[index] = updatedStudent;
      });
      _saveStudents(); 
    }
  }

  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text(
            "Apakah kamu yakin ingin menghapus ${_students[index].namaLengkap}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _students.removeAt(index);
              });
              _saveStudents(); // simpan setelah hapus
              Navigator.pop(ctx);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
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
                          name: s.namaLengkap,
                          nis: s.nisn,
                          major: s.agama,
                          address: s.alamatJalan,
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
