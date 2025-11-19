import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';

class ApiService {
  // Random User API
  static Future<ContactModel> fetchRandomContact() async {
    final res = await http.get(Uri.parse("https://randomuser.me/api/"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final user = data['results'][0];
      return ContactModel(
        name: "${user['name']['first']} ${user['name']['last']}",
        email: user['email'],
        phone: user['phone'],
        avatarUrl: user['picture']['large'],
      );
    } else {
      throw Exception("Failed to fetch random contact");
    }
  }
}