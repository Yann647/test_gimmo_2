import 'package:test_gimmo_2/models/propriete.dart';
import 'package:test_gimmo_2/models/user.dart';

enum ReservationStatue { EN_ATTENTE, ACCEPTEE, REFUSEE }

class Reservation {
  final int id;
  final DateTime datereservation;
  final ReservationStatue? statutreservation;
  final Propriete propriete;
  final User client;

  const Reservation({
    required this.id,
    required this.datereservation,
    this.statutreservation,
    required this.propriete,
    required this.client,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      datereservation: DateTime.parse(json['dateReservation']),
      statutreservation: json['statutReservation'] != null
          ? ReservationStatue.values.firstWhere(
              (e) => e.name == json['statutReservation'],
              orElse: () => ReservationStatue.EN_ATTENTE,
            )
          : null,
      propriete: Propriete.fromJson(json['propriete'] ?? {}),
      client: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datereservation': datereservation.toIso8601String(),
      'statutreservation': statutreservation?.name,
      'propriete': propriete.toJson(),
      'client': client.toJson(),
    };
  }
}
