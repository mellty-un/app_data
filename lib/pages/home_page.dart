import 'dart:convert';
import 'package:applikasi_identitas/pages/detail_page.dart';
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
List<Data> students = []; // ini dari Supabase

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
    backgroundColor: const Color.fromARGB(255, 215, 252, 255),
    floatingActionButton: FloatingActionButton(
      onPressed: _addStudent,
      backgroundColor: const Color.fromARGB(255, 133, 70, 205),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Header custom dengan teks di tengah
         Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(222, 19, 184, 179),// cream lembut
        Color.fromARGB(255, 103, 76, 126), // kuning pastel
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // logo
      Image(
        image: AssetImage("assets/images/logo.png"),
        height: 50,
      ),
      const SizedBox(width: 12),
      // teks
      const Text(
        " Data Siswa",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),


          const SizedBox(height: 16),

          // List siswa
          Expanded(
            child: _students.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada data siswa",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
  itemCount: _students.length,
  itemBuilder: (context, index) {
    final s = _students[index]; // Data dari Supabase

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              student: Student.fromData(s),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, color: Colors.blue, size: 28),
          ),
          title: Text(
            s.namaLengkap,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("NIS: ${s.nisn}"),
              Text("Alamat: ${s.alamatJalan}"),
            ],
          ),
          trailing: GestureDetector(
            onTapDown: (details) async {
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                  0,
                  0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Hapus"),
                      ],
                    ),
                  ),
                ],
              );

              if (selected == 'edit') {
                _editStudent(index);
              } else if (selected == 'delete') {
                _deleteStudent(index);
              }
            },
            child: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ),
      ),
    );
  },
)


          ),
        ],
      ),
    ),
  );
}
}