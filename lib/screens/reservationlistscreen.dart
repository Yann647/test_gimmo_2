import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/reservation.dart';
import 'package:test_gimmo_2/screens/addreservationscreen.dart';
import 'package:test_gimmo_2/screens/updatereservationscreen.dart';

class Reservationlistscreen extends StatefulWidget {
  const Reservationlistscreen({super.key});

  @override
  State<Reservationlistscreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<Reservationlistscreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    print("récupérer réservations");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('/reservations/liste');
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Nombre réservations: ${data.length}");
        setState(() {
          _reservations = data.map((e) => Reservation.fromJson(e)).toList();
        });
      } else {
        setState(() => _errorMessage = extractErrorMessage(response));
      }
    } catch (e) {
      print("ERREUR RESERVATION: $e");
      setState(() => _errorMessage = 'Erreur réseau');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addReservation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReservationScreen(),
      ),
    );

    if (result == true) {
      _fetchReservations();
    }
  }

  Future<void> _updateReservation(int id) async {
    try {
      final response = await ApiClient.put('/reservations/$id', {
        // ajoute les champs que ton API attend
        // exemple :
        // 'statutreservation': 'ACCEPTEE'
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation modifiée')),
        );

        _fetchReservations(); // rafraîchir la liste
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(response))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur modification')),
      );
    }
  }

  Future<void> _deleteReservation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: const Text('Supprimer cette réservation ?'),
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
      final response = await ApiClient.delete('/reservations/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _reservations.removeWhere((reservation) => reservation.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation supprimée')),
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
        title: const Text('Réservations'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchReservations,
              tooltip: 'Rafraîchir'),
          if (!isMobile)
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addReservation,
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
              onPressed: _addReservation,
              icon: const Icon(Icons.add),
              label: const Text("Ajouter une réservation"),
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
                        : _reservations.isEmpty
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
              onPressed: _addReservation, child: const Icon(Icons.add))
          : null,
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.event_busy_outlined,
              size: isMobile ? 80 : 120, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Aucune réservation',
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
      onRefresh: _fetchReservations,
      child: ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Text(
                    (reservation.statutreservation?.name ?? '?')
                        .substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                  '${reservation.statutreservation?.name ?? 'INCONNU'} - ${reservation.datereservation.toString().split(" ")[0]}'),
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
                              UpdateReservationScreen(reservation: reservation),
                        ),
                      );

                      if (result == true) {
                        _fetchReservations();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteReservation(reservation.id),
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
                  label: Text('Statut',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _reservations.map((reservation) {
              return DataRow(cells: [
                DataCell(Text('${reservation.id}')),
                DataCell(
                    Text(reservation.statutreservation?.name ?? 'INCONNU')),
                DataCell(
                    Text(reservation.datereservation.toString().split(' ')[0])),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateReservationScreen(
                                reservation: reservation),
                          ),
                        );

                        if (result == true) {
                          _fetchReservations();
                        }
                      },
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReservation(reservation.id),
                      tooltip: 'Supprimer',
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
