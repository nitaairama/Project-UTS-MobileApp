import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../database/db_helper.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameC = TextEditingController();
  String? _photoPath;
  final _picker = ImagePicker();
  final double borderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _usernameC.text = widget.user.username;
    _photoPath = widget.user.photo;
  }

  // Ambil foto dari kamera
  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) setState(() => _photoPath = image.path);
  }

  // Simpan perubahan profil
  Future<void> _saveProfile() async {
    final username = _usernameC.text.trim();
    if (username.isEmpty) return;

    await DBHelper.updateUserFields(widget.user.id!, {
      "username": username,
      "photo": _photoPath,
    });

    Navigator.pop(context, true); // Kembali ke HomePage dan beri tanda profile diperbarui
  }

  // Logout user
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id'); // Hapus session
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Hapus akun beserta kontak
  Future<void> _deleteAccount() async {
    if (widget.user.id != null) {
      await DBHelper.deleteAllContacts(); // Hapus semua kontak
      await DBHelper.deleteUser(widget.user.id!); // Hapus user
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id'); // Hapus session
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = (_photoPath != null && _photoPath!.isNotEmpty) ? FileImage(File(_photoPath!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          // Tombol hapus akun di pojok kanan atas dengan popup konfirmasi
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.blue[800],
            tooltip: "Hapus Akun",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Hapus Akun?"),
                  content: const Text(
                      "Semua data kontak dan akun akan dihapus permanen. Lanjutkan?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                _deleteAccount(); // Hapus akun jika dikonfirmasi
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar dengan klik untuk kamera
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatar,
                child: avatar == null ? const Icon(Icons.camera_alt, size: 48) : null,
              ),
            ),
            const SizedBox(height: 16),
            // Input username
            TextField(
              controller: _usernameC,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: const Text("Simpan"),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius)),
                ),
                onPressed: _logout,
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}