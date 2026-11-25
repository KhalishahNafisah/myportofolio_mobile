import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'api_client_test.dart' show projectJson;

class TestBackend {
  final projects = <Map<String, dynamic>>[];
  final createdBodies = <Map<String, dynamic>>[];
  final createTokens = <String?>[];
  var reads = 0;
  var logins = 0;
  var logouts = 0;
  var rejectLogin = false;
  var failRead = false;
  int? nextCreateError;

  Future<http.Response> respond(http.Request request) async {
    if (request.url.path == '/api/v1/auth/token/') {
      logins++;
      return rejectLogin
          ? http.Response('{"non_field_errors":["Invalid credentials"]}', 400)
          : http.Response(jsonEncode({'token': 'token-$logins'}), 200);
    }
    if (request.url.path == '/api/v1/auth/logout/') {
      logouts++;
      return http.Response('', 204);
    }
    if (request.method == 'GET') {
      reads++;
      expect(request.headers['authorization'], isNull);
      return failRead
          ? http.Response('unavailable', 503)
          : http.Response(
              jsonEncode(projects),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
    }
    createdBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
    createTokens.add(request.headers['authorization']);
    final error = nextCreateError;
    nextCreateError = null;
    if (error != null) return http.Response('{"detail":"Rejected"}', error);
    final saved = <String, dynamic>{...projectJson, ...createdBodies.last};
    projects.add(saved);
    return http.Response(
      jsonEncode(saved),
      201,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  ApiClient get api =>
      ApiClient(client: MockClient(respond), baseUrl: 'http://backend.test');
}

Finder field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(field('Username'), 'owner');
  await tester.enterText(field('Password'), 'password');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

Future<void> fillProject(WidgetTester tester) async {
  await tester.enterText(field('Judul Proyek'), 'Proyek baru');
  await tester.enterText(field('Deskripsi'), 'Tersimpan melalui API Django.');
  await tester.enterText(field('Tahun'), '2026');
}

void main() {
  testWidgets('guest can cancel login and cannot open the project form', (
    tester,
  ) async {
    final backend = TestBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Tambah Proyek');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(backend.logins, 0);
  });

  testWidgets('invalid credentials leave the form protected', (tester) async {
    final backend = TestBackend()..rejectLogin = true;
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Tambah Proyek');
    await login(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(
      find.text('Username atau password salah (HTTP 400).'),
      findsOneWidget,
    );
  });

  testWidgets('login, save, refreshed list, detail, and logout work together', (
    tester,
  ) async {
    final backend = TestBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Tambah Proyek');
    await login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await fillProject(tester);
    await tapText(tester, 'Simpan');
    expect(find.text('Proyek tersimpan'), findsOneWidget);
    expect(backend.createdBodies.single['year'], 2026);
    expect(backend.createdBodies.single['category'], 'web');
    expect(backend.createdBodies.single.containsKey('id'), isFalse);
    expect(backend.createTokens, ['Token token-1']);
    await tapText(tester, 'OK');
    expect(find.byType(ProjectListScreen), findsOneWidget);
    expect(find.text('Proyek baru'), findsOneWidget);
    await tapText(tester, 'Proyek baru');
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Tersimpan melalui API Django.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Logout');
    expect(backend.logouts, 1);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Add Project');
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('403 keeps input and does not report a successful save', (
    tester,
  ) async {
    final backend = TestBackend()..nextCreateError = 403;
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Tambah Proyek');
    await login(tester);
    await fillProject(tester);
    await tapText(tester, 'Simpan');
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Proyek baru'), findsOneWidget);
    expect(find.textContaining('tidak memiliki izin'), findsOneWidget);
    expect(backend.logouts, 0);
  });

  testWidgets(
    'expired token requires login again and resubmits with the new token',
    (tester) async {
      final backend = TestBackend()..nextCreateError = 401;
      await tester.pumpWidget(MyApp(apiClient: backend.api));
      await tapText(tester, 'Tambah Proyek');
      await login(tester);
      await fillProject(tester);
      await tapText(tester, 'Simpan');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(backend.logouts, 1);
      expect(backend.createdBodies.length, 1);
      await login(tester);
      expect(find.text('Proyek baru'), findsOneWidget);
      await tapText(tester, 'Simpan');
      expect(find.text('Proyek tersimpan'), findsOneWidget);
      expect(backend.createTokens, ['Token token-1', 'Token token-2']);
    },
  );

  testWidgets('public list can retry a failure and refresh an empty list', (
    tester,
  ) async {
    final backend = TestBackend()..failRead = true;
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Lihat Proyek');
    expect(find.text('Coba lagi'), findsOneWidget);
    backend.failRead = false;
    await tapText(tester, 'Coba lagi');
    expect(find.text('Belum ada proyek.'), findsOneWidget);
    backend.projects.add(Map<String, dynamic>.from(projectJson));
    await tester.drag(find.text('Belum ada proyek.'), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('Portofolio café'), findsOneWidget);
    expect(backend.reads, 3);
    expect(backend.logins, 0);
  });

  testWidgets('project validation blocks invalid data on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final backend = TestBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tapText(tester, 'Tambah Proyek');
    await login(tester);
    await fillProject(tester);
    await tester.enterText(field('Tahun'), 'bukan-tahun');
    await tester.ensureVisible(field('Project URL (opsional)'));
    await tester.enterText(field('Project URL (opsional)'), 'bukan-url');
    await tapText(tester, 'Simpan');
    expect(
      find.text('Masukkan tahun berupa bilangan bulat valid.'),
      findsOneWidget,
    );
    expect(find.text('Masukkan URL http/https yang valid.'), findsOneWidget);
    expect(backend.createdBodies, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
