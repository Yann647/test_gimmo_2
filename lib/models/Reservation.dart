enum ReservationStatue { EN_ATTENTE, ACCEPTEE, REFUSEE }

class Reservation {
  final int id;
  final DateTime datereservation;
  final ReservationStatue statureservation;

  const Reservation({
    required this.id,
    required this.datereservation,
    required this.statureservation,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      datereservation: json['datereservation'],
      statureservation: json['statureservation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datereservation': datereservation,
      'statureservation': statureservation.name,
    };
  }
}
