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
  List<ContactModel> _recent = [];
  bool _loading = true;
  final _searchC = TextEditingController();
  String _sortType = 'none';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadContacts();
  }

  // Load user profile dari SQLite + SharedPreferences
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final dbUser = await DBHelper.loginById(userId);
      setState(() => _user = dbUser);
    }
  }

  // Load kontak
  Future<void> _loadContacts() async {
    setState(() => _loading = true);
    final list = await DBHelper.getContacts();
    setState(() {
      _contacts = list;
      _filtered = list;
      // Hapus recent jika kontak sudah dihapus
      _recent = _recent.where((c) => _contacts.any((x) => x.id == c.id)).toList();
      _loading = false;
    });
    if (_sortType != 'none') _sortContacts(_sortType);
  }

  // Tambah kontak random
  Future<void> _addRandomContact() async {
    setState(() => _loading = true);
    try {
      final contact = await ApiService.fetchRandomContact();
      await DBHelper.insertContact(contact);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add random contact")));
    }
    await _loadContacts();
  }

  // Delete kontak
  Future<void> _deleteContact(int id) async {
    await DBHelper.deleteContact(id);
    await _loadContacts();
  }

  // Filter kontak
  void _search(String keyword) {
    final filtered = _contacts.where((c) {
      return c.name.toLowerCase().contains(keyword.toLowerCase()) ||
          c.email.toLowerCase().contains(keyword.toLowerCase()) ||
          c.phone.contains(keyword);
    }).toList();
    setState(() => _filtered = filtered);
    if (_sortType != 'none') _sortContacts(_sortType);
  }

  // Sort kontak
  void _sortContacts(String type) {
    setState(() {
      _sortType = type;
      if (type == 'name_asc') {
        _filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (type == 'name_desc') {
        _filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      }
    });
  }

  // Tambahkan kontak ke recent saat di-tap / di-edit
  void _addToRecent(ContactModel contact) {
    setState(() {
      _recent.removeWhere((c) => c.id == contact.id);
      _recent.insert(0, contact);
      if (_recent.length > 5) _recent = _recent.sublist(0, 5); // Max 5 recent
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatar = (_user?.photo != null && _user!.photo!.isNotEmpty)
        ? FileImage(File(_user!.photo!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PersonaList",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
        toolbarHeight: 60,
        actions: [
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
                child: avatar == null ? const Icon(Icons.person, size: 22) : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
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
                // Random
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _addRandomContact,
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    tooltip: "Add Random Contact",
                  ),
                ),
                const SizedBox(width: 6),
                // Sort
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: Colors.white),
                    onSelected: (value) => _sortContacts(value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'name_asc', child: Text('A-Z')),
                      PopupMenuItem(value: 'name_desc', child: Text('Z-A')),
                    ],
                    tooltip: "Sort Contacts",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent title
          if (_recent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.deepPurple[800])),
              ),
            ),
          if (_recent.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recent.length,
                itemBuilder: (context, i) {
                  final c = _recent[i];
                  final avatarImg = (c.photo != null && c.photo!.isNotEmpty)
                      ? FileImage(File(c.photo!))
                      : (c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null);
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContactDetailPage(contact: c)),
                      );
                      _addToRecent(c);
                      await _loadContacts();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: avatarImg as ImageProvider?,
                            child: avatarImg == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),
          // Contacts title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Contacts",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.deepPurple[800])),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Empty", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final c = _filtered[i];
                          final avatarImg = (c.photo != null && c.photo!.isNotEmpty)
                              ? FileImage(File(c.photo!))
                              : (c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null);

                          return Dismissible(
                            key: Key(c.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red[300],
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteContact(c.id!),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: avatarImg as ImageProvider?,
                                child: avatarImg == null ? const Icon(Icons.person) : null,
                              ),
                              title: Text(c.name),
                              subtitle: Text(c.email),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ContactDetailPage(contact: c)),
                                );
                                _addToRecent(c);
                                await _loadContacts();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
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
}