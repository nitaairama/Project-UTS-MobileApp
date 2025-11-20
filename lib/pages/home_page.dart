import 'dart:io';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';
import '../models/user_model.dart';
import 'contact_detail.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  List<ContactModel> _contacts = [];
  List<ContactModel> _filtered = [];
  bool _loading = true; // Flag loading
  final _searchC = TextEditingController();
  String _sortType = 'none';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadContacts();
  }

  // Load user profile dari SharedPreferences + SQLite
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      final dbUser = await DBHelper.loginById(userId);
      setState(() => _user = dbUser);
    }
  }

  // Load semua kontak dari SQLite
  Future<void> _loadContacts() async {
    setState(() => _loading = true);
    final list = await DBHelper.getContacts();
    setState(() {
      _contacts = list;
      _filtered = list;
      _loading = false;
    });
    // Jika sebelumnya sudah di-sort, terapkan lagi
    if (_sortType != 'none') _sortContacts(_sortType);
  }

  // Tambah kontak random dari API
  Future<void> _addRandomContact() async {
    setState(() => _loading = true);
    try {
      final contact = await ApiService.fetchRandomContact();
      await DBHelper.insertContact(contact);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add random contact")));
    }
    await _loadContacts();
  }

  // Delete kontak
  Future<void> _deleteContact(int id) async {
    await DBHelper.deleteContact(id);
    await _loadContacts();
  }

  // Filter kontak berdasarkan keyword search
  void _search(String keyword) {
    final filtered = _contacts.where((c) {
      return c.name.toLowerCase().contains(keyword.toLowerCase()) ||
          c.email.toLowerCase().contains(keyword.toLowerCase()) ||
          c.phone.contains(keyword);
    }).toList();
    setState(() => _filtered = filtered);
    if (_sortType != 'none') _sortContacts(_sortType);
  }

  // Sort kontak berdasarkan nama
  void _sortContacts(String type) {
    setState(() {
      _sortType = type; // simpan tipe sort
      if (type == 'name_asc') {
        _filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (type == 'name_desc') {
        _filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Avatar user di appbar
    final avatar = (_user?.photo != null && _user!.photo!.isNotEmpty)
        ? FileImage(File(_user!.photo!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        toolbarHeight: 60,
        actions: [
          // Avatar user clickable untuk masuk ke profile
          GestureDetector(
            onTap: () async {
              if (_user != null) {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage(user: _user!)),
                );
                if (updated == true) _loadUserProfile();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 18, top: 6, bottom: 6),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: avatar,
                child: avatar == null ? const Icon(Icons.person, size: 22) : null
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _searchC,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    ),
                    onChanged: _search,
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol random contact
                IconButton(
                  onPressed: _addRandomContact,
                  icon: Icon(Icons.shuffle, color: Colors.deepPurple[800]),
                  tooltip: "Add Random Contact",
                ),
                const SizedBox(width: 4),
                // Tombol sort (popup)
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort, color: Colors.deepPurple[800]),
                  onSelected: (value) => _sortContacts(value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'name_asc', child: Text('A-Z')),
                    PopupMenuItem(value: 'name_desc', child: Text('Z-A')),
                  ],
                  tooltip: "Sort Contacts",
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          // List kontak
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text("No contacts found"))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final c = _filtered[i];
                          final avatarImg = (c.photo != null && c.photo!.isNotEmpty)
                              ? FileImage(File(c.photo!))
                              : (c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatarImg as ImageProvider?,
                              child: avatarImg == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(c.name),
                            subtitle: Text(c.email),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[800]),
                              onPressed: () => _confirmDelete(context, c.id!),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ContactDetailPage(contact: c)),
                              );
                              await _loadContacts();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      // FAB untuk tambah kontak manual
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactDetailPage()),
          );
          await _loadContacts();
        },
        child: const Icon(Icons.add),
        tooltip: "Add Contact",
      ),
    );
  }

  // Konfirmasi delete kontak
  void _confirmDelete(BuildContext ctx, int id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Delete contact?"),
        content: const Text("Are you sure you want to delete this contact?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteContact(id);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red[800])),
          ),
        ],
      ),
    );
  }
}