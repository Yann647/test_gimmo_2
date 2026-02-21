import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_gimmo_2/Reservation.dart';
import 'package:test_gimmo_2/contrat.dart';
import 'package:test_gimmo_2/propriete.dart';
import 'package:test_gimmo_2/user.dart';

Future<List<Contrat>> fetchContrat() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/api/contrats'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);

    List<Contrat> posts =
        body.map((dynamic item) => Contrat.fromJson(item)).toList();
    print(posts);
    return posts;
  } else {
    throw Exception('Échec du chargement des posts');
  }
}

Future<List<Propriete>> fetchPropriete() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/api/proprietes'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);

    List<Propriete> posts =
        body.map((dynamic item) => Propriete.fromJson(item)).toList();

    return posts;
  } else {
    throw Exception('Échec du chargement des posts');
  }
}

Future<List<Reservation>> fetchReservation() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/api/reservations'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);

    List<Reservation> posts =
        body.map((dynamic item) => Reservation.fromJson(item)).toList();

    return posts;
  } else {
    throw Exception('Échec du chargement des posts');
  }
}

Future<List<User>> fetchUser() async {
  final response = await http.get(Uri.parse('http://localhost:8080/api/users'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);

    List<User> posts = body.map((dynamic item) => User.fromJson(item)).toList();

    return posts;
  } else {
    throw Exception('Échec du chargement des posts');
  }
}
