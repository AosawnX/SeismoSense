import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://fastapi-nzp0.onrender.com";

  static Future<Map<String, dynamic>?> sendPredictionRequest({
    required double magnitude,
    required double depth,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse("$_baseUrl/predict");

    final body = jsonEncode({
      "magnitude": magnitude,
      "depth": depth,
      "lat": latitude,
      "lon": longitude,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("API Exception: $e");
      return null;
    }
  }
}
