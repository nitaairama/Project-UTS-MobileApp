import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _obscurePassword = true;
  String _msg = "";

  /// Fungsi register user baru
  Future<void> _doRegister() async {
    final username = _usernameC.text.trim();
    final password = _passwordC.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _msg = "Isi semua field.");
      return;
    }

    final user = UserModel(username: username, password: password);

    try {
      await DBHelper.insertUser(user);
      setState(() => _msg = "Registrasi sukses, silahkan login.");
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Kemungkinan error: username duplicate
      setState(() => _msg = "Gagal registrasi, username mungkin sudah dipakai.");
    }
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue[800];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Register a new user",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // Input username
                TextField(
                  controller: _usernameC,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Input password
                TextField(
                  controller: _passwordC,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Pesan error atau info
                if (_msg.isNotEmpty)
                  Text(
                    _msg,
                    style: TextStyle(
                        color: _msg.contains("sukses")
                            ? Colors.green[800]
                            : Colors.red[800]),
                  ),
                const SizedBox(height: 24),
                // Tombol register
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _doRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Link ke login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Sudah punya akun? Login",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}