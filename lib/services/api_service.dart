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

  // Motivational Spark API
  static Future<String> fetchRandomMotivation({int maxLength = 80}) async {
    try {
      final res = await http.get(
        Uri.parse("https://motivational-spark-api.vercel.app/api/quotes/random")
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String text = data['quote'];

        // Batasi panjang quote
        if (text.length <= maxLength) {
          return text;
        } else {
          return "Be yourself and never surrender";
        }
      } else {
        return "Stay positive and keep going";
      }
    } catch (e) {
      return "Always the first";
    }
  }
}