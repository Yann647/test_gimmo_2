class User {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String login;
  final String password;
  final Enum role;

  const User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.login,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      login: json['login'],
      password: json['password'],
      role: json['role'],
    );
  }
}
