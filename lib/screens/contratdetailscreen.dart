import 'package:flutter/material.dart';
import 'package:test_gimmo_2/models/contrat.dart';

class ContratDetailScreen extends StatelessWidget {
  final Contrat contrat;

  const ContratDetailScreen({Key? key, required this.contrat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("detail contrat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID : ${contrat.id}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Montant : ${contrat.montant} FCFA',
                style: TextStyle(fontSize: 18)),
            // Affiche d'autres champs ici
          ],
        ),
      ),
    );
  }
}
