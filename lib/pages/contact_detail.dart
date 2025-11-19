import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../models/contact_model.dart';
import '../database/db_helper.dart';

class ContactDetailPage extends StatefulWidget {
  final ContactModel? contact;
  const ContactDetailPage({super.key, this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final _picker = ImagePicker();
  String? _photoPath;

  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();
  final _companyC = TextEditingController();

  String _phoneCountryCode = '62'; // default Indonesia

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _photoPath = widget.contact!.photo;
      _nameC.text = widget.contact!.name;
      _emailC.text = widget.contact!.email;

      // Pisahkan kode negara jika ada
      if (widget.contact!.phone.contains(' ')) {
        final parts = widget.contact!.phone.split(' ');
        _phoneCountryCode = parts[0].replaceAll('+', '');
        _phoneC.text = parts.sublist(1).join(' ');
      } else {
        _phoneC.text = widget.contact!.phone;
      }

      _addressC.text = "";
      _companyC.text = "";
    }
  }

  // Ambil foto dari kamera
  Future<void> _takePhoto() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) setState(() => _photoPath = image.path);
  }

  // Simpan kontak ke DB
  Future<void> _saveContact() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final phone = _phoneC.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama dan Email wajib diisi")));
      return;
    }

    final contact = ContactModel(
      name: name,
      email: email,
      phone: '+$_phoneCountryCode $phone', // gabungkan kode negara + nomor
      photo: _photoPath,
      avatarUrl: widget.contact?.avatarUrl,
    );

    if (widget.contact == null) {
      await DBHelper.insertContact(contact);
    } else {
      await DBHelper.updateContact(widget.contact!.id!, contact.toMap());
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    _companyC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgFile =
        (_photoPath != null && _photoPath!.isNotEmpty) ? File(_photoPath!) : null;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.contact != null ? "Edit Kontak" : "Tambah Kontak")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar dengan kamera
            GestureDetector(
              onTap: _takePhoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: imgFile != null ? FileImage(imgFile) : null,
                child: imgFile == null ? const Icon(Icons.camera_alt, size: 48) : null,
              ),
            ),
            const SizedBox(height: 16),

            // Nama
            TextField(
              controller: _nameC,
              decoration: InputDecoration(
                  labelText: "Nama",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),

            // Nomor telepon dengan kode negara global
            IntlPhoneField(
              controller: _phoneC,
              decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                      ),
              initialCountryCode: 'ID',
              onChanged: (phone) {
                _phoneCountryCode = phone.countryCode; // simpan kode negara
              },
            ),
            const SizedBox(height: 12),

            // Address
            TextField(
              controller: _addressC,
              decoration: InputDecoration(
                  labelText: "Address (opsional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),

            // Company
            TextField(
              controller: _companyC,
              decoration: InputDecoration(
                  labelText: "Company (opsional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),

            // Tombol simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Simpan", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}