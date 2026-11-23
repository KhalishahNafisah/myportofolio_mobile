import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Future<void> pressSave(WidgetTester tester) async {
  final save = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Kartu dan drawer membuka pengalaman; Home dan Back bekerja', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    // Simulasikan tombol kembali bawaan perangkat setelah Navigator.push().
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);

    // Alur proyek dari tutorial sebelumnya tetap dapat digunakan.
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('Validasi menolak spasi, judul panjang, dan URL salah', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '   ');
    await tester.enterText(fields.at(1), '   ');
    await pressSave(tester);
    expect(find.text('Judul pengalaman wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(fields.at(0), 'a' * 256);
    await tester.enterText(fields.at(1), 'Membantu pengembangan aplikasi.');
    await pressSave(tester);
    expect(
      find.text('Judul pengalaman maksimal 255 karakter.'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(0), 'Flutter Intern');
    await tester.enterText(fields.at(2), 'bukan-url');
    await pressSave(tester);
    expect(find.text('Masukkan URL http/https yang valid.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // URL dan waktu selesai boleh kosong sesuai model.
    await tester.enterText(fields.at(2), '');
    await pressSave(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Judul: Flutter Intern'), findsOneWidget);
    expect(find.textContaining('Kategori: Full-Time'), findsOneWidget);
    expect(
      find.textContaining('Waktu selesai: Masih berlangsung'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Flutter Intern'), findsOneWidget);

    // Ringkasan harus membaca perubahan terbaru.
    await tester.enterText(fields.at(0), 'Research Assistant');
    await tester.enterText(fields.at(2), 'https://example.com/foto.jpg');
    final category = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research').last);
    await tester.pumpAndSettle();
    await pressSave(tester);
    expect(find.textContaining('Judul: Research Assistant'), findsOneWidget);
    expect(find.textContaining('Kategori: Research'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('https://example.com/foto.jpg'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Pemilih tanggal dan waktu bisa diisi dan dikosongkan', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    final end = find.byType(TextFormField).last;
    await tester.ensureVisible(end);
    await tester.tap(end);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final selectedEnd = tester.widget<TextFormField>(end).controller!.text;
    expect(selectedEnd, isNotEmpty);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Flutter Intern');
    await tester.enterText(fields.at(1), 'Mengembangkan aplikasi mobile.');
    await pressSave(tester);
    expect(find.textContaining('Waktu selesai: $selectedEnd'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(end);
    await tester.tap(find.byTooltip('Hapus waktu'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(end).controller!.text, isEmpty);
  });

  testWidgets(
    'Layar 320px dan ruang keyboard tetap dapat menggulir ke Simpan',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(const MyApp());
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Tambah Pengalaman'));
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      await pressSave(tester);
      expect(find.text('Judul pengalaman wajib diisi.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
