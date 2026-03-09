# Tutoriel 3 : Finaliser l'Intégration Frontend (Flutter)

Puisque ton backend (Spring Boot) est déjà prêt et fonctionnel, et que nous avons posé les bases de la connexion dans les tutoriels précédents, il est temps de **finaliser la partie Frontend (Flutter)**.

Dans ce guide, nous allons aller plus loin pour rendre ton application professionnelle : ajouter les requêtes manquantes (Modification, Suppression), intégrer le geste de rafraîchissement ("Pull-to-Refresh"), afficher des pages de détails, et mapper les derniers modèles.

---

## 1) Compléter le Client API (`api_client.dart`)

Jusqu'à présent, nous avions configuré le `GET` et le `POST`. Mais pour mettre à jour ou supprimer une donnée, il nous faut le `PUT` et le `DELETE`.

**Fichier → `lib/api_client.dart` → Action : Ajouter les méthodes PUT et DELETE :**

```dart
  // ... Code précédent (get et post) ...

  // Méthode pour la modification (PUT)
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode(body)
    );
  }

  // Méthode pour la suppression (DELETE)
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${Config.baseUrl}$endpoint');
    return await http.delete(
      url,
      headers: await _headers()
    );
  }
}
```

---

## 2) Ajouter la Modification et la Suppression (CRUD complet)

Prenons l'exemple de tes contrats, mais cela s'applique à n'importe quelle entité (Propriétés, Réservations).

### 2.1 La suppression (DELETE)
Dans ton écran qui liste les contrats (`contratlistscreen.dart`), lorsque l'utilisateur glisse sur un élément ou clique sur une corbeille, on doit lancer la suppression.

```dart
Future<void> _deleteContrat(int id) async {
  // Optionnel : Afficher un dialogue de confirmation ici

  try {
    final response = await ApiClient.delete('/contrats/$id'); // Appelle l'API

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Succès : Retire visuellement l'élément de la liste
      setState(() {
        _contrats.removeWhere((contrat) => contrat.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrat supprimé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(response))),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur lors de la suppression')),
    );
  }
}
```

### 2.2 La modification (PUT)
Pour modifier, tu peux réutiliser l'écran `AddContractScreen` en lui passant un contrat existant, ou créer une page spécifique `EditContractScreen`.

Si l'utilisateur sauvegarde ses modifications :
```dart
Future<void> _updateContrat(int id) async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.put('/contrats/$id', {
      'titre': _titreController.text,
      'montant': double.parse(_montantController.text),
    });

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Quitte l'écran et signale le succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(response))),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## 3) Améliorer l'Expérience Utilisateur (UX)

### 3.1 Le Pull-to-Refresh (Rafraîchir vers le bas)
C'est un standard moderne. Dans ta `contratlistscreen.dart` (ou toute vue de liste), tu vas envelopper ton `ListView.builder` avec un `RefreshIndicator`.

```dart
body: _isLoading
  ? const Center(child: CircularProgressIndicator())
  : _errorMessage != null
      ? Center(child: Text(_errorMessage!))
      : RefreshIndicator(
          onRefresh: _fetchContrats, // Appelle la même API GET
          child: ListView.builder(
            itemCount: _contrats.length,
            // Permet de scroller même si la liste est vide (pour pull-to-refresh)
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final contrat = _contrats[index];
              return ListTile(
                title: Text(contrat.titre ?? 'Sans titre'),
                subtitle: Text('${contrat.montant} CFA'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteContrat(contrat.id), // Le bouton de suppression
                ),
                onTap: () {
                   // Ouvrir la page de détail au clic
                },
              );
            },
          ),
        ),
```

### 3.2 La Page de Détail
Plutôt que de tout afficher dans la liste (ce qui prend trop de place), crée un écran `ContratDetailScreen.dart` :

```dart
class ContratDetailScreen extends StatelessWidget {
  final Contrat contrat;

  const ContratDetailScreen({Key? key, required this.contrat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contrat.titre ?? 'Détails')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID : ${contrat.id}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Montant : ${contrat.montant} FCFA', style: TextStyle(fontSize: 18)),
            // Affiche d'autres champs ici
          ],
        ),
      ),
    );
  }
}
```
**Pour l'appeler depuis ta liste** (`onTap` du ListTile ci-dessus) :
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ContratDetailScreen(contrat: contrat),
  ),
);
```

---

## 4) Finaliser TOUS tes Modèles

Dans l'application Gimmo, tu as plusieurs fichiers modèles autres que `user.dart` et `contrat.dart`, notamment pour les **Propriétés** ou les **Liens**. Assure-toi qu'ils ont tous un pont clair entre JSON et Dart.

### Exemple : `propriete.dart`

```dart
class Propriete {
  final int id;
  final String titre;
  final String description;
  final double prix;
  final String type; // Maison, Terrain, Appartement...

  Propriete({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.type,
  });

  factory Propriete.fromJson(Map<String, dynamic> json) {
    return Propriete(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? 'Sans Nom',
      description: json['description'] ?? '',
      // Gestion de sécurité sur les nombres décimaux :
      prix: json['prix'] != null ? double.parse(json['prix'].toString()) : 0.0,
      type: json['type'] ?? 'Non défini',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'type': type,
    };
  }
}
```

---

## 5) Redirection après la connexion (Login)

Un détail très important est la redirection de l'utilisateur une fois qu'il s'est connecté avec succès. Quand l'API retourne un statut `200` et le token, il faut stocker ce token et renvoyer l'utilisateur vers la page d'accueil (`HomeScreen`).

Dans ton `loginscreen.dart`, la fonction de connexion devrait ressembler à ceci :

```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final response = await ApiClient.post('/auth/login', {
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200) {
      // 1. On récupère le token renvoyé par le backend
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];

      // 2. On le sauvegarde localement
      await Storage.saveToken(token);

      // 3. IMPORTANT : On navigue vers l'écran d'accueil et on efface l'historique
      // (pour éviter que le bouton "Retour" de l'Android ne ramène au login)
      if (mounted) { // Vérification de sécurité avec Flutter
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false, // Supprime toutes les pages précédentes
          );
      }
    } else {
      // Afficher une erreur si identifiants incorrects
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Identifiants incorrects')),
      );
    }
  } catch (e) {
    // Afficher une erreur de réseau
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur réseau. Veuillez réessayer.')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 6) Résumé des actions à suivre

Maintenant que tout est là, voici ta **feuille de route finale** :
1. **Ouvre `api_client.dart`** et ajoute les méthodes `put` et `delete`.
2. **Implémente le Pull-to-Refresh** via `RefreshIndicator()` sur toutes tes pages de liste (`contratlistscreen.dart`, `reservation.dart`, etc.).
3. **Ajoute un bouton Supprimer (DELETE)** dans tes `ListTile` pour permettre aux utilisateurs de gérer leurs données.
4. **Transforme tes Formulaires d'ajout en Formulaires d'édition** (ajoute le fait qu'ils puissent prendre en paramètre optionnel des données existantes pour appeler un `PUT` au lieu d'un `POST`).
5. **Vérifie la redirection dans `loginscreen.dart`** pour t'assurer que l'utilisateur est bien redirigé vers l'`HomeScreen` une fois connecté.
6. **Applique les `factory fromJson` à tous les fichiers dans le dossier modèles** de ton UI pour qu'aucune erreur de "parsing" ne remonte !
