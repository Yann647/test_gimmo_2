import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/user.dart';

class UpdateUserScreen extends StatefulWidget {
  final User user;

  const UpdateUserScreen({super.key, required this.user});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;

  String? _role;
  final List<String> _roles = ['ADMIN', 'CLIENT'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.user.nom);
    _prenomController = TextEditingController(text: widget.user.prenom);
    _emailController = TextEditingController(text: widget.user.email);
    _telephoneController = TextEditingController(text: widget.user.telephone);

    _role = widget.user.role.name;
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put(
        '/users/${widget.user.id}',
        {
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'telephone': _telephoneController.text,
          'role': _role,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur modifié')),
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
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier utilisateur")),
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
