import 'package:test_gimmo_2/models/propriete.dart';
import 'package:test_gimmo_2/models/user.dart';

enum ContratType { LOCATION, VENTE, BAIL }

class Contrat {
  final int id;
  final DateTime datedebut;
  final DateTime datefin;
  final double montant;
  final ContratType typecontrat;
  final Propriete propriete;
  final User client;

  const Contrat({
    required this.id,
    required this.datedebut,
    required this.datefin,
    required this.montant,
    required this.typecontrat,
    required this.propriete,
    required this.client,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id: json['id'],
      datedebut: json['datedebut'],
      datefin: json['datefin'],
      montant: json['montant'],
      typecontrat: json['typecontrat'],
      propriete: json['propriete'],
      client: json['client'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datedebut': datedebut,
      'datefin': datefin,
      'montant': montant,
      'typecontrat': typecontrat.name,
      'propriete': propriete.toJson(),
      'client': client.toJson(),
    };
  }
}
