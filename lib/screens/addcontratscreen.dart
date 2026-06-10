import 'package:flutter/material.dart';
import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';

class AddContratScreen extends StatefulWidget {
  const AddContratScreen({super.key});

  @override
  State<AddContratScreen> createState() => _AddContratScreenState();
}

class _AddContratScreenState extends State<AddContratScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _typeContrat;
  int? _proprieteId;
  int? _userId;
  DateTime? _dateDebut;
  final _montantController = TextEditingController();
  final _dateController = TextEditingController(); // pour affichage
  final _titreController = TextEditingController();
  bool _isLoading = false;

  List<String> _types = []; // À charger depuis API
  List<Map<String, dynamic>> _proprietes = [];
  List<Map<String, dynamic>> _users = [];

  Future<void> _submitContrat() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post('/contrats', {
        'titre': _titreController.text,
        'typecontrat': _typeContrat,
        'montant': int.parse(_montantController.text),
        'proprieteId': _proprieteId,
        'userId': _userId,
        'datedebut': _dateDebut?.toIso8601String(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrat ajouté avec succès')),
        );
        Navigator.pop(context, true);
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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: appels API
    setState(() {});
  }

  @override
  void dispose() {
    _montantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveContrat() async {
    if (_formKey.currentState!.validate()) {
      // TODO: POST
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Contrat sauvegardé')));
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _typeContrat = null;
      _proprieteId = null;
      _userId = null;
      _dateDebut = null;
      _montantController.clear();
      _dateController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un contrat')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Type de contrat
                      const Text('Type de contrat',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _typeContrat,
                        hint: const Text('Sélectionner'),
                        items: [
                          const DropdownMenuItem(
                              value: '', child: Text('Sélectionner')),
                          ..._types.map((type) =>
                              DropdownMenuItem(value: type, child: Text(type))),
                        ],
                        onChanged: (value) =>
                            setState(() => _typeContrat = value),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Propriété
                      const Text('Adresse',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _proprieteId,
                        hint: const Text('Sélectionner'),
                        items: [
                          const DropdownMenuItem(
                              value: 0, child: Text('Sélectionner')),
                          ..._proprietes.map((p) => DropdownMenuItem(
                              value: p['id'], child: Text(p['adresse']))),
                        ],
                        onChanged: (value) =>
                            setState(() => _proprieteId = value),
                        validator: (value) =>
                            value == null || value == 0 ? 'Requis' : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Client
                      const Text('Client',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _userId,
                        hint: const Text('Sélectionner'),
                        items: [
                          const DropdownMenuItem(
                              value: 0, child: Text('Sélectionner')),
                          ..._users.map((u) => DropdownMenuItem(
                                value: u['id'],
                                child: Text('${u['nom']} ${u['prenom']}'),
                              )),
                        ],
                        onChanged: (value) => setState(() => _userId = value),
                        validator: (value) =>
                            value == null || value == 0 ? 'Requis' : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date de signature
                      const Text('Date de signature',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (_) => _dateDebut == null ? 'Requis' : null,
                        decoration: InputDecoration(
                          hintText: 'JJ/MM/AAAA',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Montant
                      const Text('Montant',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _montantController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Requis' : null,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          prefixText: 'FCFA ',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Boutons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitContrat,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Terminer'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetForm,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Annuler'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
