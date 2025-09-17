import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String nis;
  final String major;
  final String address;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.name,
    required this.nis,
    required this.major,
    required this.address,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage("assets/images/profile.png"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("NIS: $nis"),
                 Text("Jurusan: -"),
                  Text("Alamat: $address"),
                  Text("Desa: $desa"),
                  Text("Kecamatan: $kecamatan"),
                  Text("Kabupaten: $kabupaten"),
                  Text("Provinsi: $provinsi"),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text("Edit"),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
