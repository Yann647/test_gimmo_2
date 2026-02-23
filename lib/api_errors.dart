import 'dart:convert';
import 'package:http/http.dart' as http;

String extractErrorMessage(http.Response response) {
  try {
    final body = jsonDecode(response.body);
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
  } catch (_) {}
  return 'Erreur (${response.statusCode})';
}
