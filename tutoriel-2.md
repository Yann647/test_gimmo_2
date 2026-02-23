# Tutoriel : Connecter son application Flutter à un backend Spring Boot

Ce document te guide **pas à pas** pour relier une UI Flutter (déjà faite) à une API Spring Boot (déjà fonctionnelle), en suivant la structure réelle de ton dossier `lib/` :

* `main.dart`
* `loginscreen.dart`
* `signupscreen.dart`
* `homescreen.dart`
* `contratlistscreen.dart`
* `addcontractscreen.dart`
* `Reservation.dart`
* Modèles : `user.dart`, `contrat.dart`, `propriete.dart`, `lien.dart`

**Règles d’exécution**

* Tu ne réécris pas l’app entière.
* Tu appliques le même pattern à chaque écran : **loading / error / data**.
* Tu testes chaque endpoint dans Postman avant Flutter.

---

## 0) Pré-requis (à faire une seule fois)

### 0.1 Dépendances Flutter

**Fichier → `pubspec.yaml` → Action : ajouter les packages → Explication :**
On a besoin d’un client HTTP et d’un stockage local pour le token.

Ajoute dans `dependencies:` :

```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.2
```

Puis exécute :

* `flutter pub get`

### 0.2 Vérifier le backend (check rapide)

**Backend → Action : confirmer les endpoints → Explication :**
Avant Flutter, tu dois connaître **exactement** :

* `POST /auth/register` payload + réponse
* `POST /auth/login` payload + réponse (où est le token ?)
* `GET /contrats` réponse (liste ? pagination ?)
* `POST /contrats` payload + réponse
* `GET/POST /reservations` selon ton cas

**Sortie attendue :** tu notes 2 exemples JSON par endpoint : request + response.

---

## 1) Lecture du projet (5–10 min)

### 1.1 À quoi sert chaque fichier

**Fichier → Action → Explication :**

* `main.dart` : démarre l’app, choisit l’écran initial (login vs home), définit les routes.
* `loginscreen.dart` : formulaire login + appel API login + stockage token.
* `signupscreen.dart` : formulaire inscription + appel API register.
* `homescreen.dart` : écran après login, point d’accès aux autres pages + logout.
* `contratlistscreen.dart` : charge la liste des contrats depuis l’API.
* `addcontractscreen.dart` : envoie un nouveau contrat à l’API.
* `Reservation.dart` : même logique que contrats mais pour réservations.
* `*.dart` modèles : convertissent JSON ⇄ objets Dart.

### 1.2 Repérer la navigation actuelle

**Fichier → `main.dart` → Action : repérer `MaterialApp`, `routes`, `home` → Explication :**
On va brancher la logique de session ici (token présent ?).

---

## 2) Préparer l’intégration backend (sans refactor lourd)

### 2.1 Base URL centralisée

**Fichier → `lib/config.dart` (à créer) → Action : définir `baseUrl` → Explication :**
Sur Android émulateur, `localhost` pointe vers l’émulateur, donc on utilise `10.0.2.2`.

```dart
class Config {
  // Android emulator → 10.0.2.2
  // iOS simulator / web → localhost
  // téléphone réel → IP de ton PC sur le réseau
  static const String baseUrl = 'http://10.0.2.2:8080/api';
}
```

**Contrôle :** si ton backend n’a pas de `/api`, enlève-le.

### 2.2 Stockage token

**Fichier → `lib/storage.dart` (à créer) → Action : save/get/clear token → Explication :**
Le token JWT doit survivre au redémarrage de l’app.

```dart
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _key = 'jwt_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

### 2.3 Client API (GET/POST)

**Fichier → `lib/api_client.dart` (à créer) → Action : centraliser HTTP → Explication :**
Un seul endroit gère headers JSON + Bearer token.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'storage.dart';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return http.get(url, headers: await _headers());
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return http.post(url, headers: await _headers(), body: jsonEncode(body));
  }
}
```

### 2.4 Extraction d’erreurs

**Fichier → `lib/api_errors.dart` (à créer) → Action : extraire message serveur → Explication :**
Le backend renvoie souvent `{ "message": "..." }`.

```dart
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
```

---

## 3) Pattern unique d’écran connecté (à répliquer partout)

### 3.1 Les 3 états

**Fichier → écran X → Action : déclarer 3 variables → Explication :**

* `_isLoading` : affiche un loader
* `_errorMessage` : affiche une erreur
* `_data` : affiche le contenu

Pattern minimal (liste) :

```dart
bool _isLoading = false;
String? _errorMessage;
```

### 3.2 Règle d’or

**Action → Explication :**

* `setState(() => _isLoading = true)` avant l’appel
* `try/catch`
* `finally` remet `_isLoading = false`

---

## 4) Auth complète

### 4.1 Inscription — `signupscreen.dart`

#### 4.1.1 Brancher le submit

**Fichier → `lib/signupscreen.dart` → Action : créer `_submit()` → Explication :**
Le bouton devient asynchrone. Il valide d’abord le formulaire, puis appelle l’API.

Ajoute dans `_SignupScreenState` :

```dart
bool _isLoading = false;

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.post('/auth/register', {
      'nom': _nomController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(response))),
      );
    }
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### 4.1.2 Brancher le bouton

**Fichier → `signupscreen.dart` → Action : remplacer `onPressed` → Explication :**
On bloque le bouton pendant le chargement.

* `onPressed: _isLoading ? null : _submit`

#### 4.1.3 Afficher le loader

**Fichier → `signupscreen.dart` → Action : afficher un loader sur le bouton → Explication :**
Si `_isLoading` est vrai, montre un indicateur.

---

### 4.2 Connexion — `loginscreen.dart`

#### 4.2.1 Créer `_login()`

**Fichier → `lib/loginscreen.dart` → Action : appeler login + stocker token → Explication :**
Tu récupères le token et tu le sauvegardes pour les requêtes suivantes.

```dart
import 'dart:convert';

bool _isLoading = false;

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.post('/auth/login', {
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await Storage.saveToken(token);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identifiants invalides')),
      );
    }
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### 4.2.2 Brancher le bouton

* `onPressed: _isLoading ? null : _login`

---

## 5) Session + protection des écrans

### 5.1 Décider l’écran de départ

**Fichier → `lib/main.dart` → Action : choisir `home` selon token → Explication :**
Au démarrage, si token existe → home, sinon → login.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await Storage.getToken();

  runApp(MaterialApp(
    home: token != null ? HomeScreen() : LoginScreen(),
    routes: {
      '/login': (_) => LoginScreen(),
      '/home': (_) => HomeScreen(),
      '/signup': (_) => SignupScreen(),
    },
  ));
}
```

### 5.2 Logout

**Fichier → `lib/homescreen.dart` → Action : clear token + redirect → Explication :**

```dart
Future<void> logout() async {
  await Storage.clearToken();
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## 6) Contrats

### 6.1 Liste — `contratlistscreen.dart`

#### 6.1.1 Déclarer les variables

**Fichier → `contratlistscreen.dart` → Action → Explication :**
Une liste + états.

```dart
import 'dart:convert';

List<Contrat> _contrats = [];
bool _isLoading = true;
String? _errorMessage;
```

#### 6.1.2 Charger au démarrage

**Action :** `initState()` appelle `_fetchContrats()`.

```dart
@override
void initState() {
  super.initState();
  _fetchContrats();
}
```

#### 6.1.3 Écrire `_fetchContrats()`

```dart
Future<void> _fetchContrats() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final response = await ApiClient.get('/contrats');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _contrats = data.map((e) => Contrat.fromJson(e)).toList();
      });
    } else {
      setState(() => _errorMessage = extractErrorMessage(response));
    }
  } catch (_) {
    setState(() => _errorMessage = 'Erreur réseau');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### 6.1.4 Adapter le `build()` (règles)

* si `_isLoading` → loader
* sinon si `_errorMessage != null` → texte erreur
* sinon si `_contrats.isEmpty` → “Aucun contrat”
* sinon → `ListView.builder`

### 6.2 Ajout — `addcontractscreen.dart`

#### 6.2.1 Envoyer le formulaire

**Fichier → `addcontractscreen.dart` → Action : `_submitContrat()` → Explication :**

```dart
bool _isLoading = false;

Future<void> _submitContrat() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.post('/contrats', {
      'titre': _titreController.text,
      'montant': int.parse(_montantController.text),
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(response))),
      );
    }
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### 6.2.2 Forcer le refresh après retour

**Fichier → `contratlistscreen.dart` → Action : attendre le résultat du `push` → Explication :**
Quand tu ouvres `AddContractScreen`, récupère `true` pour recharger.

Pseudo-pattern :

* `final reload = await Navigator.push(...);`
* `if (reload == true) _fetchContrats();`

---

## 7) Réservations — `Reservation.dart`

### 7.1 Identifier le type d’écran

**Fichier → `Reservation.dart` → Action : vérifier UI → Explication :**

* Si c’est une **liste** : copie le pattern `contratlistscreen.dart` en remplaçant endpoint + modèle.
* Si c’est un **formulaire** : copie `addcontractscreen.dart`.

### 7.2 Endpoints typiques

* Liste : `GET /reservations`
* Création : `POST /reservations`

---

## 8) Modèles (obligatoire)

### 8.1 Exemple — `user.dart`

**Fichier → `user.dart` → Action : `fromJson/toJson` → Explication :**
Flutter lit du JSON, mais l’app manipule des objets.

```dart
class User {
  final int id;
  final String nom;
  final String? email;

  User({required this.id, required this.nom, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
    };
  }
}
```

### 8.2 Règles de mapping

* Si le backend renvoie `"1"` au lieu de `1`, convertir : `int.parse(json['id'].toString())`.
* Si un champ peut manquer : le rendre `String?`.
* Pour une liste d’objets : `List<dynamic>` puis `map`.

---

## 9) Debug + pièges fréquents (checklist)

1. **Android émulateur** : `10.0.2.2` (pas `localhost`).
2. **Device réel** : utiliser l’IP du PC (ex: `http://192.168.x.x:8080`).
3. **401** : token non envoyé ou format mauvais → vérifier `Bearer ` + espace.
4. **CORS** : seulement pour Flutter Web (navigateur). Spring Boot doit autoriser.
5. **Type mismatch** : `String` vs `int` → corriger dans `fromJson`.
6. **Réseau** : vérifier firewall / port / backend lancé.
7. **Toujours logguer** : imprimer `response.statusCode` et `response.body` en dev.

---

## 10) Plan d’exécution (ordre conseillé)

1. Créer `config.dart`, `storage.dart`, `api_client.dart`, `api_errors.dart`
2. Faire login (`loginscreen.dart`) et vérifier stockage token
3. Mettre la session dans `main.dart`
4. Charger la liste contrats (`contratlistscreen.dart`)
5. Créer un contrat (`addcontractscreen.dart`) + refresh liste
6. Brancher réservations (`Reservation.dart`)
7. Finaliser modèles (`*.dart`) et corriger les types
