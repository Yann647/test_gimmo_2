import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'storage.dart';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return http.get(url, headers: await _headers());
  }

  // Méthode pour ajouter (POST)
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return http.post(url, headers: await _headers(), body: jsonEncode(body));
  }

  // Méthode pour la modification (PUT)
  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return await http.put(url,
        headers: await _headers(), body: jsonEncode(body));
  }

  // Méthode pour la suppression (DELETE)
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return await http.delete(url, headers: await _headers());
  }
}
