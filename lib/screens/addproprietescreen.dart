import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';

class AddProprieteScreen extends StatefulWidget {
  const AddProprieteScreen({super.key});

  @override
  State<AddProprieteScreen> createState() => _AddProprieteScreenState();
}

class _AddProprieteScreenState extends State<AddProprieteScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _type;
  String? _disponible;
  final _adresseController = TextEditingController();
  final _prixController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  final List<String> _types = ['MAISON', 'APPARTEMENT', 'TERRAIN'];
  final List<String> _disponibles = ['OUI', 'NON'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post('/proprietes', {
        'adresse': _adresseController.text,
        'prix': double.parse(_prixController.text),
        'description': _descriptionController.text,
        'typepropriete': _type,
        'disponible': _disponible,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriété ajoutée')),
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
      appBar: AppBar(title: const Text("Ajouter une propriété")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: "Adresse"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Prix"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items: _types
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v),
                decoration: const InputDecoration(labelText: "Type"),
                validator: (v) => v == null ? "Requis" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _disponible,
                items: _disponibles
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _disponible = v),
                decoration: const InputDecoration(labelText: "Disponible"),
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
