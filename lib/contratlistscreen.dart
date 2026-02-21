/* import 'package:flutter/material.dart';
import 'package:test_gimmo_2/contrat.dart';

class ContratListScreen extends StatefulWidget {
  const ContratListScreen({super.key});

  @override
  State<ContratListScreen> createState() => _ContratListScreenState();
}

class _ContratListScreenState extends State<ContratListScreen> {
  List<Contrat> _contrats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContrats();
  }

  Future<void> _loadContrats() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simule chargement
    setState(() {
      _contrats = []; // Remplacer par vos données
      _isLoading = false;
    });
  }

  void _addContrat() {
    // Navigation vers l'écran d'ajout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirection vers ajout contrat (TODO)')),
    );
  }

  void _editContrat(int id) {
    // TODO: édition
  }

  void _deleteContrat(int id) {
    // TODO: suppression avec confirmation
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
            onPressed: _loadContrats,
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
        child: Card(
          elevation: 2,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contrats.isEmpty
                  ? _buildEmptyState(isMobile)
                  : isMobile
                      ? _buildMobileList()
                      : _buildTabletDesktopList(),
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _contrats.length,
      itemBuilder: (context, index) {
        final contrat = _contrats[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                contrat.type.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${contrat.type} - ${contrat.montant} FCFA',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('📅 ${contrat.date}'),
                Text('🏠 ${contrat.propriete}'),
                Text('👤 ${contrat.client}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editContrat(contrat.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteContrat(contrat.id),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
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
                  DataCell(Text(contrat.type)),
                  DataCell(Text(contrat.date)),
                  DataCell(Text('${contrat.montant} FCFA')),
                  DataCell(Text(contrat.propriete)),
                  DataCell(Text(contrat.client)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editContrat(contrat.id),
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
 */