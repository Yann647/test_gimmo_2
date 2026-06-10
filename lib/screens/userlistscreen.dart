import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/user.dart';
import 'package:test_gimmo_2/screens/adduserscreen.dart';
import 'package:test_gimmo_2/screens/updateuserscreen.dart';

class Userlistscreen extends StatefulWidget {
  const Userlistscreen({super.key});

  @override
  State<Userlistscreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<Userlistscreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    print("récupérer utilisateurs");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('/users/liste');
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Nombre utilisateurs: ${data.length}");
        setState(() {
          _users = data.map((e) => User.fromJson(e)).toList();
        });
      } else {
        setState(() => _errorMessage = extractErrorMessage(response));
      }
    } catch (e) {
      print("ERREUR: $e");
      setState(() => _errorMessage = 'Erreur réseau');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddUserScreen(),
      ),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Supprimer cet utilisateur ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await ApiClient.delete('/users/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _users.removeWhere((user) => user.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(response))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur suppression')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchUsers,
              tooltip: 'Rafraîchir'),
          if (!isMobile)
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addUser,
                tooltip: 'Ajouter'),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 BOUTON AJOUT
            ElevatedButton.icon(
              onPressed: _addUser,
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un utilisateur"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 12),

            // 🔽 LISTE
            Expanded(
              child: Card(
                elevation: 2,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _users.isEmpty
                            ? _buildEmptyState(isMobile)
                            : isMobile
                                ? _buildMobileList()
                                : _buildTabletDesktopList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _addUser, child: const Icon(Icons.add))
          : null,
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.people_outline,
              size: isMobile ? 80 : 120, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Aucun utilisateur',
              style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Cliquez + pour ajouter',
              style: TextStyle(
                  fontSize: isMobile ? 14 : 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildMobileList() {
    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Text(user.role.name.substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text('${user.nom} ${user.prenom}'),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text(user.role.name),
                    Text(user.telephone),
                  ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateUserScreen(user: user),
                        ),
                      );

                      if (result == true) {
                        _fetchUsers();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteUser(user.id),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletDesktopList() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(
                  label:
                      Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Nom',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Rôle',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Téléphone',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _users.map((user) {
              return DataRow(cells: [
                DataCell(Text('${user.id}')),
                DataCell(Text('${user.nom} ${user.prenom}')),
                DataCell(Text(user.email)),
                DataCell(Text(user.role.name)),
                DataCell(Text(user.telephone)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateUserScreen(user: user),
                          ),
                        );

                        if (result == true) {
                          _fetchUsers();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user.id),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
