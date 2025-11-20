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
  String _phoneCountryCode = '62';

  // Controllers
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();
  final _companyC = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      _photoPath = widget.contact!.photo;
      _nameC.text = widget.contact!.name;
      _emailC.text = widget.contact!.email;
      _addressC.text = widget.contact!.address ?? '';
      _companyC.text = widget.contact!.company ?? '';

      // Pisahkan kode negara dan nomor agar tetap sesuai saat edit
      if (widget.contact!.phone.contains(' ')) {
        final parts = widget.contact!.phone.split(' ');
        _phoneCountryCode = parts[0].replaceAll('+', '');
        _phoneC.text = parts.sublist(1).join(' ');
      } else {
        _phoneC.text = widget.contact!.phone;
      }
    }
  }

  // Ambil foto dari kamera
  Future<void> _takePhoto() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) setState(() => _photoPath = img.path);
  }

  // Simpan / update kontak
  Future<void> _saveContact() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final phone = _phoneC.text.trim();
    final address = _addressC.text.trim();
    final company = _companyC.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Name & email required")));
      return;
    }

    final contact = ContactModel(
      name: name,
      email: email,
      phone: '+$_phoneCountryCode $phone',
      photo: _photoPath,
      avatarUrl: widget.contact?.avatarUrl,
      address: address,
      company: company,
    );

    // Insert atau update
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
        centerTitle: true,
        title: Text(
          widget.contact != null ? "Edit Contact" : "Add Contact",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar dengan kamera
            GestureDetector(
              onTap: _takePhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imgFile != null ? FileImage(imgFile) : null,
                child: imgFile == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 38),

            // Nama
            TextField(
              controller: _nameC,
              decoration: InputDecoration(
                labelText: "Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Phone dengan kode negara (Intl)
            IntlPhoneField(
              controller: _phoneC,
              decoration: InputDecoration(
                labelText: 'Phone',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
              initialCountryCode: _phoneCountryCode,
              onChanged: (phone) {
                _phoneCountryCode = phone.countryCode; // angka tetap
              },
            ),
            const SizedBox(height: 12),

            // Address + Company
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressC,
                    decoration: InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _companyC,
                    decoration: InputDecoration(
                      labelText: "Company",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),

            // Tombol Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Save", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}