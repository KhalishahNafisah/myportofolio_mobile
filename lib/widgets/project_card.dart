import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    final label = item.name == 'Logout' && !isLoggedIn ? 'Login' : item.name;
    final icon = item.name == 'Logout' && !isLoggedIn ? Icons.login : item.icon;
    return Material(
      // Setiap kartu menggunakan warna yang ditentukan pada daftar menu.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (item.name == 'Lihat Proyek') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
            );
            return;
          }
          if (item.name == 'Tambah Proyek' ||
              item.name == 'Tambah Pengalaman') {
            final allowed = await ensureLoggedIn(context);
            if (!context.mounted || !allowed) return;
            final Widget page = item.name == 'Tambah Proyek'
                ? const ProjectFormPage()
                : const ExperienceFormPage();
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            return;
          }
          if (item.name == 'Logout') {
            final auth = context.read<AuthState>();
            if (!auth.isLoggedIn) {
              await ensureLoggedIn(context);
              return;
            }
            await auth.logout();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kamu sudah keluar dari aplikasi.')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
