import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  // Key dibuat sekali pada State agar Form dapat diakses saat Simpan ditekan.
  final _formKey = GlobalKey<FormState>();
  final _endController = TextEditingController();

  String _title = '';
  String _description = '';
  String _category = 'full-time';
  String _thumbnail = '';
  DateTime? _endedAt;

  static const _categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  // Validator mengembalikan pesan jika salah, atau null jika valid.
  String? _requiredText(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    if (maxLength != null && text.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  // URL gambar opsional dengan protokol http/https.
  String? _validateThumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > 200) return 'URL maksimal 200 karakter.';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'Masukkan URL http/https yang valid.';
    }
    return null;
  }

  // Model memakai DateTimeField, sehingga pilih tanggal sekaligus waktu.
  // Tidak ada aturan urutan tanggal di model: started_at diisi otomatis.
  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    // Setelah await, pastikan halaman masih aktif dan pilihan tidak dibatalkan.
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endedAt ?? DateTime.now()),
    );
    if (!mounted || time == null) return;
    setState(() {
      _endedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _endController.text =
          '${date.day}/${date.month}/${date.year} ${time.format(context)}';
    });
  }

  void _save() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    // save() menjalankan onSaved; ini belum menyimpan data ke database.
    form.save();
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Pengalaman'),
        scrollable: true,
        content: Text(
          'Judul: $_title\n'
          'Deskripsi: $_description\n'
          'Kategori: ${_categories[_category]}\n'
          'URL gambar: ${_thumbnail.isEmpty ? "-" : _thumbnail}\n'
          'Waktu selesai: ${_endedAt == null ? "Masih berlangsung" : _endController.text}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Controller milik halaman dibersihkan saat halaman dilepas.
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengalaman'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengalaman',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _requiredText(value, 'Judul pengalaman', maxLength: 255),
                  onSaved: (value) => _title = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => _requiredText(value, 'Deskripsi'),
                  onSaved: (value) => _description = value!.trim(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
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
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                  validator: (value) => _categories.containsKey(value)
                      ? null
                      : 'Pilih kategori yang valid.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'URL Gambar (opsional)',
                    hintText: 'https://example.com/gambar.jpg',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: _validateThumbnail,
                  onSaved: (value) => _thumbnail = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // readOnly + picker menghasilkan DateTime valid; null diizinkan model.
                  controller: _endController,
                  readOnly: true,
                  onTap: _pickEndDate,
                  decoration: InputDecoration(
                    labelText: 'Waktu Selesai (opsional)',
                    helperText:
                        'Waktu lokal; kosong berarti masih berlangsung.',
                    helperMaxLines: 2,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _endedAt == null ? 'Pilih waktu' : 'Hapus waktu',
                      icon: Icon(
                        _endedAt == null ? Icons.calendar_today : Icons.clear,
                      ),
                      onPressed: () {
                        if (_endedAt == null) {
                          _pickEndDate();
                        } else {
                          setState(() {
                            _endedAt = null;
                            _endController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _save, child: const Text('Simpan')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
