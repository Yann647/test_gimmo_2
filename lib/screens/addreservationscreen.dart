import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';

class AddReservationScreen extends StatefulWidget {
  const AddReservationScreen({super.key});

  @override
  State<AddReservationScreen> createState() => _AddReservationScreenState();
}

class _AddReservationScreenState extends State<AddReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _userId;
  int? _proprieteId;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _proprietes = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      final usersRes = await ApiClient.get('/users/liste');
      final propRes = await ApiClient.get('/proprietes/liste');

      setState(() {
        _users = List<Map<String, dynamic>>.from(jsonDecode(usersRes.body));
        _proprietes = List<Map<String, dynamic>>.from(jsonDecode(propRes.body));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement données')),
      );
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post('/reservations', {
        'userId': _userId,
        'proprieteId': _proprieteId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation ajoutée')),
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
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter réservation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// 🔥 UTILISATEUR
              DropdownButtonFormField<int>(
                value: _userId,
                items: _users.map<DropdownMenuItem<int>>((u) {
                  return DropdownMenuItem<int>(
                    value: u['id'] as int, // ✅ CORRECTION ICI
                    child: Text('${u['nom']} ${u['prenom']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _userId = v),
                decoration: const InputDecoration(labelText: "Utilisateur"),
                validator: (v) => v == null ? "Requis" : null,
              ),

              const SizedBox(height: 12),

              /// 🔥 PROPRIETE
              DropdownButtonFormField<int>(
                value: _proprieteId,
                items: _proprietes.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem<int>(
                    value: p['id'] as int, // ✅ CORRECTION ICI
                    child: Text(p['adresse']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _proprieteId = v),
                decoration: const InputDecoration(labelText: "Propriété"),
                validator: (v) => v == null ? "Requis" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
