import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/propriete.dart';

class UpdateProprieteScreen extends StatefulWidget {
  final Propriete propriete;

  const UpdateProprieteScreen({super.key, required this.propriete});

  @override
  State<UpdateProprieteScreen> createState() => _UpdateProprieteScreenState();
}

class _UpdateProprieteScreenState extends State<UpdateProprieteScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _adresseController;
  late TextEditingController _prixController;
  late TextEditingController _descriptionController;

  String? _type;
  String? _disponible;

  bool _isLoading = false;

  final List<String> _types = ['MAISON', 'APPARTEMENT', 'TERRAIN'];
  final List<String> _disponibles = ['OUI', 'NON'];

  @override
  void initState() {
    super.initState();

    _adresseController = TextEditingController(text: widget.propriete.adresse);
    _prixController =
        TextEditingController(text: widget.propriete.prix.toString());
    _descriptionController =
        TextEditingController(text: widget.propriete.description);

    _type = widget.propriete.typepropriete.name;
    _disponible = widget.propriete.disponible.name;
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put(
        '/proprietes/${widget.propriete.id}',
        {
          'adresse': _adresseController.text,
          'prix': double.parse(_prixController.text),
          'description': _descriptionController.text,
          'typepropriete': _type,
          'disponible': _disponible,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriété modifiée')),
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
    _adresseController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier propriété")),
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _disponible,
                items: _disponibles
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _disponible = v),
                decoration: const InputDecoration(labelText: "Disponible"),
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
