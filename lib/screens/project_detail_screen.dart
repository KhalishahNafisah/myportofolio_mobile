import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final category = project.categoryDisplay.isEmpty
        ? project.category
        : project.categoryDisplay;
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.projectImageUrl.isNotEmpty) ...[
              Image.network(
                project.projectImageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Gambar tidak dapat dimuat.'),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('$category • ${project.year}'),
            const SizedBox(height: 16),
            Text(project.description),
            if (project.projectUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              SelectableText('Tautan: ${project.projectUrl}'),
            ],
            const SizedBox(height: 16),
            Text('Jumlah star: ${project.starCount}'),
            if (project.id != null) ...[
              const SizedBox(height: 8),
              SelectableText('ID: ${project.id}'),
            ],
          ],
        ),
      ),
    );
  }
}
