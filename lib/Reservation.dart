class Reservation {
  final int id;
  final DateTime datereservation;
  final Enum statureservation;

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
}
