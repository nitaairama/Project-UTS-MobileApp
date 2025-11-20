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

  // Hapus akun beserta kontak dengan konfirmasi
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete", style: TextStyle(color: Colors.red[800]),)),
        ],
      ),
    );

    if (confirm == true && widget.user.id != null) {
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
  void dispose() {
    _usernameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = (_photoPath != null && _photoPath!.isNotEmpty) ? FileImage(File(_photoPath!)) : null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text("Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        actions: [
          // Tombol hapus akun
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteAccount,
            tooltip: "Delete Account",
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Avatar user
              GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: avatar,
                  child: avatar == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              const SizedBox(height: 38),
              
              // Input username
              TextField(
                controller: _usernameC,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Row tombol Save & Logout
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ),
                  const SizedBox(width: 12), // jarak antar tombol
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}