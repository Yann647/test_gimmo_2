import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/models/contrat.dart';

class UpdateContratScreen extends StatefulWidget {
  final Contrat contrat;

  const UpdateContratScreen({super.key, required this.contrat});

  @override
  State<UpdateContratScreen> createState() => _UpdateContratScreenState();
}

class _UpdateContratScreenState extends State<UpdateContratScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _montantController;
  late TextEditingController _dateController;

  String? _typeContrat;
  int? _proprieteId;
  int? _userId;
  DateTime? _dateDebut;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final c = widget.contrat;

    _montantController = TextEditingController(text: c.montant.toString());
    _dateController = TextEditingController(
        text: "${c.datedebut.day}/${c.datedebut.month}/${c.datedebut.year}");

    _typeContrat = c.typecontrat.name;
    _proprieteId = c.propriete.id;
    _userId = c.client.id;
    _dateDebut = c.datedebut;
  }

  Future<void> _updateContrat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put(
        '/contrats/${widget.contrat.id}',
        {
          'typecontrat': _typeContrat,
          'montant': double.parse(_montantController.text),
          'proprieteId': _proprieteId,
          'userId': _userId,
          'datedebut': _dateDebut?.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrat modifié avec succès')),
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _dateDebut = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier contrat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(labelText: 'Date début'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateContrat,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
