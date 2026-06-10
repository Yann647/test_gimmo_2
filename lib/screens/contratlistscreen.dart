import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/contrat.dart';
import 'package:test_gimmo_2/screens/addcontratscreen.dart';
import 'package:test_gimmo_2/screens/updatecontratscreen.dart';
import 'dart:convert';

import 'package:test_gimmo_2/screens/contratdetailscreen.dart';

class ContratListScreen extends StatefulWidget {
  const ContratListScreen({super.key});

  @override
  State<ContratListScreen> createState() => _ContratListScreenState();
}

class _ContratListScreenState extends State<ContratListScreen> {
  List<Contrat> _contrats = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchContrats();
  }

  Future<void> _fetchContrats() async {
    print("recuperer contrat");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('/contrats/liste');
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Nombre contrats: ${data.length}");
        setState(() {
          _contrats = data.map((e) => Contrat.fromJson(e)).toList();
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

  void _addContrat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddContratScreen(),
      ),
    );

    if (result == true) {
      _fetchContrats(); // refresh liste après ajout
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchContrats,
            tooltip: 'Rafraîchir',
          ),
          if (!isMobile) // Bouton d'ajout dans l'AppBar pour les grands écrans
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addContrat,
              tooltip: 'Ajouter',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 BOUTON AJOUT ICI
            ElevatedButton.icon(
              onPressed: _addContrat,
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un contrat"),
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
                        : _contrats.isEmpty
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
              onPressed: _addContrat,
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
              Icons.description_outlined,
              size: isMobile ? 80 : 120,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contrat enregistré',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le bouton + pour créer un contrat',
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
        onRefresh: _fetchContrats, // Appelle la même API GET
        child: ListView.builder(
          itemCount: _contrats.length,
          itemBuilder: (context, index) {
            final contrat = _contrats[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    contrat.typecontrat.name
                        .toString()
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  '${contrat.typecontrat.name} - ${contrat.montant} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('📅 ${contrat.datedebut.toString().split(' ')[0]}'),
                    Text('🏠 ${contrat.propriete.adresse}'),
                    Text('👤 ${contrat.client.nom} ${contrat.client.prenom}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateContratScreen(contrat: contrat),
                          ),
                        );

                        if (result == true) {
                          _fetchContrats();
                        }
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteContrat(contrat.id),
                    ),
                  ],
                ),
                onTap: () {
                  // Ouvrir la page de détail au clic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContratDetailScreen(contrat: contrat),
                    ),
                  );
                },
                isThreeLine: true,
              ),
            );
          },
        ));
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
                  label: Text('Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Montant',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Propriété',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Client',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _contrats.map((contrat) {
              return DataRow(
                cells: [
                  DataCell(Text('${contrat.id}')),
                  DataCell(Text(contrat.typecontrat.name.toString())),
                  DataCell(Text(contrat.datedebut.toString().split(' ')[0])),
                  DataCell(Text('${contrat.montant} FCFA')),
                  DataCell(Text(contrat.propriete.adresse)),
                  DataCell(
                      Text('${contrat.client.nom} ${contrat.client.prenom}')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateContratScreen(contrat: contrat),
                            ),
                          );

                          if (result == true) {
                            _fetchContrats();
                          }
                        },
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContrat(contrat.id),
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
