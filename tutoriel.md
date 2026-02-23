# Tutoriel Complet : Connecter son application Flutter à un backend Spring Boot

Ce guide pas à pas est conçu pour t'accompagner dans la connexion de ton application Flutter (dont l'interface est déjà prête) à ton API Spring Boot fonctionnelle. Nous allons dynamiser tes écrans un par un.

## 0) Prérequis : Les dépendances

**Fichier → `pubspec.yaml` → Action : Ajouter les packages `http` et `shared_preferences` → Explication :**
Ton application a besoin d'outils pour faire des requêtes réseau (http) et pour stocker le token de connexion dans la mémoire du téléphone (shared_preferences).

Ajoute ceci sous `dependencies:` :
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```
*N'oublie pas de lancer `flutter pub get` dans ton terminal pour télécharger ces paquets.*

---

## 1) Lecture de ton projet (Ce qu'on va modifier)

Voici comment nous allons structurer notre travail sur tes fichiers existants dans `lib/` :
* **`main.dart`** : On va le modifier pour lire le token au démarrage et rediriger soit vers le Login, soit vers le Home.
* **`loginscreen.dart` & `signupscreen.dart`** : On va remplacer les boutons "virtuels" par de vrais appels réseau pour s'inscrire et se connecter.
* **`homescreen.dart`** : On ajoutera la déconnexion.
* **`contratlistscreen.dart`** : On va remplacer la liste statique par une liste venue du serveur.
* **`addcontractscreen.dart`** : On va envoyer les données du formulaire au serveur.
* **`Reservation.dart`** : Suivra la même logique que les contrats (liste et ajout).
* **`user.dart`, `contrat.dart`, `propriete.dart`, `lien.dart`** : On va leur ajouter la capacité de se transformer depuis/vers du format JSON.

---

## 2) Préparer la communication avec le backend

Nous allons créer 4 petits fichiers dans `lib/` pour centraliser la logique réseau.

### 2.1 Configuration de l'URL
**Fichier → `lib/config.dart` (nouveau) → Action : Créer une variable pour l'URL de base → Explication :**
Si tu changes d'API ou si tu passes en production, tu n'auras qu'un seul fichier à modifier.

```dart
class Config {
  // L'adresse IP 10.0.2.2 permet à l'émulateur Android d'accéder au localhost de ton PC.
  // Port 8080 : port par défaut de Spring Boot. Modifie-le si besoin.
  static const String baseUrl = 'http://10.0.2.2:8080/api';
}
```

### 2.2 Gestion du Token JWT
**Fichier → `lib/storage.dart` (nouveau) → Action : Créer les méthodes pour sauvegarder, lire et supprimer le token → Explication :**
Spring Boot va te fournir un JWT après la connexion. Ce fichier permet de le garder en mémoire pour ne pas le perdre quand on ferme l'app.

```dart
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _tokenKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

### 2.3 Le Client API Principal
**Fichier → `lib/api_client.dart` (nouveau) → Action : Créer une classe pour les requêtes HTTP → Explication :**
Ce fichier va automatiquement injecter le "Token" dans toutes tes requêtes. Ainsi, tu n'auras pas à le faire manuellement à chaque fois.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'storage.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    return await http.get(Uri.parse('${Config.baseUrl}$endpoint'), headers: await _getHeaders());
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('${Config.baseUrl}$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
  }
}
```

### 2.4 Gestion universelle des erreurs
**Fichier → `lib/api_errors.dart` (nouveau) → Action : Créer une fonction d'extraction d'erreur → Explication :**
Spring Boot renvoie souvent l'erreur dans un format précis (ex: `{"message": "Email déjà utilisé"}`). Cette fonction va lire ce JSON.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

String extractErrorMessage(http.Response response) {
  try {
    // On essaie de lire le corps de la réponse erreur générée par Spring Boot
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Erreur inattendue (Code ${response.statusCode})';
  } catch (e) {
    return 'Erreur de connexion serveur (Code ${response.statusCode})';
  }
}
```

---

## 3) L'Authentification

Pour chaque écran, le pattern est le même :
1) Déclarer `bool _isLoading = false;` dans l'état (State).
2) Créer une méthode asynchrone qui fait le `try/catch`.
3) Appeler `setState(() => _isLoading = ...)` pour rafraîchir l'écran.

### 3.1 Création de compte (Signup)
**Fichier → `lib/signupscreen.dart` → Action : Ajouter la logique d'inscription → Explication :**
On va envoyer les contrôleurs de texte à l'API. Cherche la classe d'état (ex: `_SignupScreenState`) et ajoute ces lignes.

```dart
bool _isLoading = false;

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return; // Valide le formulaire
  setState(() => _isLoading = true); // Affiche le loader

  try {
    final response = await ApiClient.post('/auth/register', {
      'nom': _nomController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compte créé !')));
      Navigator.pushReplacementNamed(context, '/login'); // Redirige vers login
    } else {
      String errorMessage = extractErrorMessage(response);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau / Serveur inaccessible')));
  } finally {
    setState(() => _isLoading = false); // Retire le loader
  }
}
```

**Où modifier l'interface (UI) ?**
Dans ta méthode `build`, trouve ton bouton d'inscription (ex: `ElevatedButton`) et modifie-le comme suit :
```dart
// Si _isLoading est vrai, on affiche un rond qui tourne, sinon le bouton normal
_isLoading
  ? Center(child: CircularProgressIndicator())
  : ElevatedButton(
      onPressed: _submit, // Au clic, lance notre nouvelle méthode
      child: Text('S\'inscrire'),
    )
```

### 3.2 Connexion (Login)
**Fichier → `lib/loginscreen.dart` → Action : Ajouter la logique de connexion → Explication :**
Même logique, mais cette fois le serveur renvoie un token que l'on doit enregistrer avec `Storage`.

```dart
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
      final jsonResponse = jsonDecode(response.body);
      // Le JSON contient souvent {"token": "eyJhb..."} selon ton Spring Boot
      await Storage.saveToken(jsonResponse['token']);
      Navigator.pushReplacementNamed(context, '/home'); // Accès à l'app !
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Identifiants incorrects')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau : Vérifiez votre connexion')));
  } finally {
    setState(() => _isLoading = false);
  }
}
```

*(Pense à modifier ton bouton "Se connecter" dans le `build` comme fait pour le bouton d'inscription, en utilisant `_isLoading ? CircularProgressIndicator() : ElevatedButton(...)`)*.

---

## 4) Protéger les écrans (Gestion de session client)

Comment éviter que l'utilisateur doive se reconnecter à chaque fois qu'il ouvre l'application ?

### 4.1 Vérifier la session au démarrage
**Fichier → `lib/main.dart` → Action : Remplacer la fonction `main` par une initialisation asynchrone → Explication :**
Avant de dessiner le premier écran, Flutter va lire le stockage. Si un token existe, il affiche `HomeScreen`, sinon `LoginScreen`.

```dart
void main() async {
  // Obligatoire quand on utilise `await` avant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await Storage.getToken();
  Widget initialScreen = (token != null) ? HomeScreen() : LoginScreen();

  runApp(MaterialApp(
    title: 'Mon App Gimmo',
    home: initialScreen,
    routes: {
      '/login': (context) => LoginScreen(),
      '/home': (context) => HomeScreen(),
    },
  ));
}
```

### 4.2 Ajouter un bouton Déconnexion
**Fichier → `lib/homescreen.dart` → Action : Supprimer le token → Explication :**
On vide la mémoire contenant le token et on chasse l'utilisateur vers l'écran de Login.

```dart
void _logout(BuildContext context) async {
  await Storage.clearToken();
  Navigator.pushReplacementNamed(context, '/login');
}
```
Dans l'AppBar de ton HomeScreen, place par exemple :
```dart
AppBar(
  title: Text('Accueil'),
  actions: [
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: () => _logout(context),
    )
  ],
)
```

---

## 5) Afficher et Modifier des Données (Les Contrats)

### 5.1 Afficher la liste des contrats
**Fichier → `lib/contratlistscreen.dart` → Action : Appeler `GET /contrats` au chargement de la page → Explication :**
Plutôt que d'attendre un clic, on va chercher les données dès l'ouverture de la page avec `initState`.

1. Ajoute ces variables dans la classe `_ContratListScreenState` :
```dart
List<Contrat> _contrats = [];
bool _isLoading = true;
String? _errorMessage;

@override
void initState() {
  super.initState();
  _fetchContrats(); // Se lance tout seul à l'ouverture de la page
}

Future<void> _fetchContrats() async {
  setState(() { _isLoading = true; _errorMessage = null; });
  try {
    final response = await ApiClient.get('/contrats');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        _contrats = jsonList.map((json) => Contrat.fromJson(json)).toList();
      });
    } else {
      setState(() => _errorMessage = extractErrorMessage(response));
    }
  } catch (e) {
    setState(() => _errorMessage = 'Erreur réseau : Impossible de charger les contrats');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Mise à jour de l'UI (`build()`) :**
Dans le corps (body) de ton Scaffold, gère les 3 états :
```dart
body: _isLoading
    ? Center(child: CircularProgressIndicator()) // 1. Ça charge
    : _errorMessage != null
        ? Center(child: Text(_errorMessage!)) // 2. Y'a une erreur
        : _contrats.isEmpty
            ? Center(child: Text("Aucun contrat pour le moment.")) // 3a. C'est vide
            : ListView.builder( // 3b. On affiche les données
                itemCount: _contrats.length,
                itemBuilder: (context, index) {
                  final contrat = _contrats[index];
                  return ListTile(
                    title: Text(contrat.titre ?? 'Sans titre'),
                    subtitle: Text('Montant : ${contrat.montant} FCFA'),
                  );
                },
              ),
```

### 5.2 Formulaire de création d'un contrat
**Fichier → `lib/addcontractscreen.dart` → Action : Envoyer les données et rafraîchir la liste → Explication :**
Tout comme le Login, on envoie un POST, mais avec les données du contrat.

```dart
bool _isLoading = false;

Future<void> _submitContrat() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.post('/contrats', {
      'titre': _titreController.text,
      // Pense à convertir les champs texte en nombre si le backend le demande
      'montant': double.tryParse(_montantController.text) ?? 0,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Retourne en arrière ET envoie "true" pour dire que la donnée a changé
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(response))));
    }
  } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'enregistrement')));
  } finally {
    setState(() => _isLoading = false);
  }
}
```

*(N'oublie pas dans `contratlistscreen.dart`, là où tu as le bouton pour ajouter un contrat :)*
```dart
// Ajoute un 'await' sur la navigation pour capter le retour
// onPressed: () async {
//   bool? hasNewData = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContractScreen()));
//   if (hasNewData == true) {
//      _fetchContrats(); // On rafraîchit la liste si y'a du neuf !
//   }
// }
```

---

## 6) Les Réservations (`Reservation.dart`)

**Action : Dupliquer les patterns → Explication :**
Ton fichier `Reservation.dart` concerne probablement la gestion des réservations. La philosophie est stricte et ne change jamais :
* Ton écran doit afficher une liste ? → Copie le mécanisme de `_fetchContrats()` (avec GET `/reservations`, `initState`, et `ListView.builder`).
* Ton écran a un formulaire d'envoi ? → Copie le mécanisme de `_submitContrat()` (avec POST `/reservations` et `try/catch`).

---

## 7) Rendre les Modèles intelligents (Obligatoire)

Flutter est "fortement typé", Spring Boot (Java) aussi, mais entre les deux c'est du JSON (du simple texte). Les modèles doivent faire la traduction.

**Fichiers → `lib/user.dart`, `lib/contrat.dart`, etc. → Action : Ajouter les méthodes `fromJson` et `toJson` → Explication :**

Prends tes classes existantes, et rajoute ceci. Fais très attention à la null-safety (les clés qui manquent provoqueraient un crash de l'app si non gérées).

### Exemple complet : `contrat.dart`
```dart
class Contrat {
  final int id;
  final String? titre;
  final double montant;

  Contrat({
    required this.id,
    this.titre,
    required this.montant
  });

  // Depuis le JSON (Spring Boot -> Flutter)
  factory Contrat.fromJson(Map<String, dynamic> json) {
    return Contrat(
      // Si la variable ne peut pas être nulle, gère une valeur par défaut en cas de bug API : ?? 0
      id: json['id'] ?? 0,
      titre: json['titre'], // Peut être null, donc pas grave si absent

      // Les nombres causent souvent des crashes si parsés en int au lieu de double
      montant: json['montant'] != null ? double.parse(json['montant'].toString()) : 0.0,
    );
  }

  // Vers le JSON (Flutter -> Spring Boot)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'montant': montant,
    };
  }
}
```
**À FAIRE : Répète ce schéma de `factory Class.fromJson(Map<String, dynamic> json)` sur TOUS tes autres modèles : `propriete.dart`, `lien.dart` et `user.dart`.**

---

## 8) Checklist de debugging et Pièges fréquents

Si rien ne s'affiche, ne panique pas et vérifie cette liste de survie :

1. **J'ai une erreur `Connection refused`**
   * Es-tu sur l'émulateur Android ? Alors l'URL de base dans ton `config.dart` DOIT être `http://10.0.2.2:8080/api`, et pas `localhost`.
2. **J'ai une erreur CORS (Sur Flutter Web uniquement)**
   * Ferme Flutter, va dans ton Spring Boot, et ajoute `@CrossOrigin(origins = "*")` au-dessus de tes `@RestController`.
3. **Mon écran reste blanc sans rien faire**
   * Ouvre la "Run Console" ou le "Terminal" dans ton éditeur. Il y a probablement une erreur rouge écrit de ce type : `type 'String' is not a subtype of type 'num'`. Cela signifie que ton `fromJson` s'est loupé (le serveur a envoyé un texte "1500" au lieu du chiffre `1500`. Utilise `.toString()` et `double.tryParse(...)` pour sécuriser ton parsing).
4. **J'ai des erreurs `401 Unauthorized` ou de Token**
   * Dans ton Spring Boot, vérifie le filtre JWT. Dans Flutter, vérifie en imprimant le token `print(await Storage.getToken());` qu'il n'est pas "null". Assure-toi que le header est écrit exactement `'Bearer $token'` (avec un espace après Bearer).
5. **Le Formulaire ne marche pas**
   * Tu as oublié d'envelopper tes `TextFormField` à l'intérieur d'un widget `Form(key: _formKey, child: ...)` dans la méthode `build`.
6. **Le mot de passe en clair**
   * N'oublie pas de mettre `obscureText: true` dans ton `TextFormField` de mot de passe !

**Le conseil final et ultime :**
Avant d'écrire la moindre ligne de code Flutter, **ouvre le logiciel Postman ou Insomnia**, et essaie tes appels (Inscription, Connexion, Création de Contrat) sur ton serveur local Spring Boot. Si Postman a une erreur, ton backend a un souci. Si Postman marche, ton problème est dans ton code Flutter.
