enum ContratType { LOCATION, VENTE, BAIL }

class Contrat {
  final int id;
  final DateTime datedebut;
  final DateTime datefin;
  final double montant;
  final ContratType typecontat;

  const Contrat({
    required this.id,
    required this.datedebut,
    required this.datefin,
    required this.montant,
    required this.typecontat,
  });

  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      id: json['id'],
      datedebut: json['datedebut'],
      datefin: json['datefin'],
      montant: json['montant'],
      typecontat: json['typecontat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datedebut': datedebut,
      'datefin': datefin,
      'montant': montant,
      'typecontat': typecontat.name,
    };
  }
}
