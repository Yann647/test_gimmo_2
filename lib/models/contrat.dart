import 'package:test_gimmo_2/models/propriete.dart';
import 'package:test_gimmo_2/models/user.dart';

enum ContratType { LOCATION, VENTE, BAIL }

class Contrat {
  final int id;
  final DateTime datedebut;
  final DateTime? datefin;
  final double montant;
  final ContratType typecontrat;
  final Propriete propriete;
  final User client;

  const Contrat({
    required this.id,
    required this.datedebut,
    this.datefin,
    required this.montant,
    required this.typecontrat,
    required this.propriete,
    required this.client,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id: json['id'],
      datedebut: DateTime.parse(json['dateDebut']),
      datefin: json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
      montant: (json['montant'] as num).toDouble(),
      typecontrat: ContratType.values.firstWhere(
        (e) => e.name == json['typeContrat'],
      ),
      propriete: Propriete.fromJson(json['propriete']),
      client: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datedebut': datedebut.toIso8601String(),
      'datefin': datefin?.toIso8601String(),
      'montant': montant,
      'typeContrat': typecontrat.name,
      'propriete': propriete.toJson(),
      'client': client.toJson(),
    };
  }
}
