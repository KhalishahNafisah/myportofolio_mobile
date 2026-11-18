import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _projectName = '';
  String _description = '';
  String _category = 'Web Development';
  String _technologies = '';
  String _projectLink = '';

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  void _resetForm() {
    _formKey.currentState!.reset();

    setState(() {
      _projectName = '';
      _description = '';
      _category = 'Web Development';
      _technologies = '';
      _projectLink = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Proyek',
                  hintText: 'Nama Proyek',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _projectName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama proyek tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Proyek',
                  hintText: 'Deskripsi Proyek',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi proyek tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: 'Web Development',
                decoration: const InputDecoration(
                  labelText: 'Kategori Proyek',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Teknologi yang Digunakan',
                  hintText: 'Contoh: Flutter, Django, Figma',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _technologies = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Tautan Proyek',
                  hintText: 'URL Proyek (opsional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _projectLink = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Proyek berhasil ditambahkan!'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama Proyek: $_projectName'),
                                Text('Deskripsi: $_description'),
                                Text('Kategori: $_category'),
                                Text('Teknologi: $_technologies'),
                                Text('Tautan: $_projectLink'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _resetForm();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
