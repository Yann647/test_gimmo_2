import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/reservation.dart';

class UpdateReservationScreen extends StatefulWidget {
  final Reservation reservation;

  const UpdateReservationScreen({super.key, required this.reservation});

  @override
  State<UpdateReservationScreen> createState() =>
      _UpdateReservationScreenState();
}

class _UpdateReservationScreenState extends State<UpdateReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _statut;

  final List<String> _statuts = ['EN_ATTENTE', 'ACCEPTEE', 'REFUSEE'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _statut = widget.reservation.statutreservation?.name;
  }

  Future<void> _update() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put(
        '/reservations/${widget.reservation.id}',
        {
          'statutreservation': _statut,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation modifiée')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier réservation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _statut,
                items: _statuts
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _statut = v),
                decoration: const InputDecoration(labelText: "Statut"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _update,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Modifier"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
