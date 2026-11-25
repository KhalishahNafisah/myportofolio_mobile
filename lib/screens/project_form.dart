import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = 'web';
  String _yearText = DateTime.now().year.toString();
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  static const _categories = {
    'event': 'Event Management',
    'marketing': 'Marketing & Communications',
    'creative': 'Creative Production',
    'web': 'Web Development',
  };

  String? _requiredText(String? value, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Kolom ini wajib diisi.';
    if (maxLength != null && text.length > maxLength) {
      return 'Maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _validateUrl(String? value, {required int maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > maxLength) return 'URL maksimal $maxLength karakter.';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'Masukkan URL http/https yang valid.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final allowed = await ensureLoggedIn(context);
      if (!mounted || !allowed) return;
      final token = context.read<AuthState>().token;
      if (token == null) return;
      final project = Project(
        title: _title.trim(),
        description: _description.trim(),
        category: _category,
        year: int.parse(_yearText.trim()),
        projectUrl: _projectUrl.trim(),
        projectImageUrl: _projectImageUrl.trim(),
      );
      final saved = await context.read<ApiClient>().createProject(
        project,
        token: token,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek tersimpan'),
          content: Text('${saved.title} berhasil disimpan ke database Django.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProjectListScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        _showMessage(error.userMessage);
        final loggedIn = await ensureLoggedIn(context);
        if (!mounted) return;
        if (loggedIn) ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }
      _showMessage(error.userMessage);
    } on Exception {
      if (!mounted) return;
      _showMessage('Tidak dapat menghubungi server.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label,
    ValueChanged<String> onChanged, {
    String? initialValue,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: !_isSubmitting,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Proyek'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(
                  'Judul Proyek',
                  (value) => _title = value,
                  validator: (value) => _requiredText(value, maxLength: 255),
                ),
                _field(
                  'Deskripsi',
                  (value) => _description = value,
                  validator: _requiredText,
                  maxLines: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) _category = value;
                          },
                    validator: (value) => _categories.containsKey(value)
                        ? null
                        : 'Pilih kategori yang valid.',
                  ),
                ),
                _field(
                  'Tahun',
                  (value) => _yearText = value,
                  initialValue: _yearText,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final year = int.tryParse(value?.trim() ?? '');
                    if (year == null || year < 0 || year > 2147483647) {
                      return 'Masukkan tahun berupa bilangan bulat valid.';
                    }
                    return null;
                  },
                ),
                _field(
                  'Project URL (opsional)',
                  (value) => _projectUrl = value,
                  keyboardType: TextInputType.url,
                  validator: (value) => _validateUrl(value, maxLength: 200),
                ),
                _field(
                  'Project Image URL (opsional)',
                  (value) => _projectImageUrl = value,
                  keyboardType: TextInputType.url,
                  validator: (value) => _validateUrl(value, maxLength: 500),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
