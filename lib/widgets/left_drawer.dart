import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  Future<void> _openPage(
    BuildContext context,
    Widget page, {
    bool requiresLogin = false,
  }) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (requiresLogin) {
      final allowed = await ensureLoggedIn(navigator.context);
      if (!navigator.mounted || !allowed) return;
    }
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _openPage(context, MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Lihat Proyek'),
            onTap: () => _openPage(context, const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _openPage(
              context,
              const ProjectFormPage(),
              requiresLogin: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            onTap: () => _openPage(
              context,
              const ExperienceFormPage(),
              requiresLogin: true,
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              final navigator = Navigator.of(context);
              if (!isLoggedIn) {
                navigator.pop();
                await ensureLoggedIn(navigator.context);
                return;
              }
              final auth = context.read<AuthState>();
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              await auth.logout();
              if (!messenger.mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Kamu sudah keluar dari aplikasi.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
