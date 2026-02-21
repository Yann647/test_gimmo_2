class Propriete {
  final int id;
  final String adresse;
  final double prix;
  final String imagePath;
  final Enum typepropriete;
  final String description;
  final Enum disponible;

  const Propriete({
    required this.id,
    required this.adresse,
    required this.prix,
    required this.imagePath,
    required this.typepropriete,
    required this.description,
    required this.disponible,
  });

  factory Propriete.fromJson(Map<String, dynamic> json) {
    return Propriete(
      id: json['id'],
      adresse: json['adresse'],
      prix: json['prix'],
      imagePath: json['imagePath'],
      typepropriete: json['typepropriete'],
      description: json['description'],
      disponible: json['disponible'],
    );
  }
}
