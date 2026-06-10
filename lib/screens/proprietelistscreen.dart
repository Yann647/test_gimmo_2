import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/propriete.dart';
import 'package:test_gimmo_2/screens/addproprietescreen.dart';
import 'package:test_gimmo_2/screens/updateproprietescreen.dart';

class Proprietelistscreen extends StatefulWidget {
  const Proprietelistscreen({super.key});

  @override
  State<Proprietelistscreen> createState() => _ProprieteListScreenState();
}

class _ProprieteListScreenState extends State<Proprietelistscreen> {
  final _formKey = GlobalKey<FormState>();

  String? _typepropriete;
  String? _disponible;
  String? _adresse;
  final _prixController = TextEditingController();
  List<Propriete> _proprietes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProprietes();
  }

  Future<void> _fetchProprietes() async {
    print("récupérer propriétés");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('/proprietes/liste');
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Nombre propriétés: ${data.length}");
        setState(() {
          _proprietes = data.map((e) => Propriete.fromJson(e)).toList();
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

  void _addPropriete() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProprieteScreen(), // à créer
      ),
    );

    if (result == true) {
      _fetchProprietes();
    }
  }

  Future<void> _updatePropriete(int id) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put('/proprietes/$id', {
        'adresse': _adresse,
        'prix': double.parse(_prixController.text),
        // Ajoutez autres champs selon votre formulaire
      });

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
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

  Future<void> _deletePropriete(int id) async {
    // Dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette propriété ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await ApiClient.delete('/proprietes/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _proprietes.removeWhere((propriete) => propriete.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriété supprimée avec succès')),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propriétés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProprietes,
            tooltip: 'Rafraîchir',
          ),
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addPropriete,
              tooltip: 'Ajouter',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 BOUTON AJOUT
            ElevatedButton.icon(
              onPressed: _addPropriete,
              icon: const Icon(Icons.add),
              label: const Text("Ajouter une propriété"),
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
                        : _proprietes.isEmpty
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
              onPressed: _addPropriete,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: isMobile ? 80 : 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune propriété enregistrée',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le bouton + pour créer une propriété',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return RefreshIndicator(
      onRefresh: _fetchProprietes,
      child: ListView.builder(
        itemCount: _proprietes.length,
        itemBuilder: (context, index) {
          final propriete = _proprietes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  propriete.typepropriete.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                '${propriete.typepropriete.name} - ${propriete.prix.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('📍 ${propriete.adresse}'),
                  Text('${propriete.description}'),
                  Text(
                    propriete.disponible == Proprietedisponible.OUI
                        ? 'Disponible'
                        : 'Non disponible',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateProprieteScreen(propriete: propriete),
                        ),
                      );

                      if (result == true) {
                        _fetchProprietes();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deletePropriete(propriete.id),
                  ),
                ],
              ),
              onTap: () {
                // TODO: Naviguer vers détail si nécessaire
              },
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
                  label: Text('Type',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Adresse',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Prix',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Disponible',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _proprietes.map((propriete) {
              return DataRow(
                cells: [
                  DataCell(Text('${propriete.id}')),
                  DataCell(Text(propriete.typepropriete.name)),
                  DataCell(Text(propriete.adresse)),
                  DataCell(Text('${propriete.prix.toStringAsFixed(0)} FCFA')),
                  DataCell(Text(propriete.disponible.name)),
                  DataCell(Text(propriete.description)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateProprieteScreen(propriete: propriete),
                            ),
                          );

                          if (result == true) {
                            _fetchProprietes();
                          }
                        },
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePropriete(propriete.id),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
