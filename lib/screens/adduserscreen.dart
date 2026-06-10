import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();

  String? _role;
  final List<String> _roles = ['ADMIN', 'CLIENT'];

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post('/users', {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'role': _role,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ajouté')),
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
      appBar: AppBar(title: const Text("Ajouter utilisateur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                items: _roles
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v),
                decoration: const InputDecoration(labelText: "Rôle"),
                validator: (v) => v == null ? "Requis" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Enregistrer"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
