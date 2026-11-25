import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

const projectJson = {
  'id': 'a046071e-c358-4d53-878b-0680a089f754',
  'title': 'Portofolio café',
  'description': 'Proyek dari Django.',
  'category': 'web',
  'category_display': 'Web Development',
  'year': 2026,
  'project_url': 'https://example.com',
  'project_image_url': '',
  'star_count': 2,
  'is_starred': false,
};

void main() {
  ApiClient clientFor(Future<http.Response> Function(http.Request) handler) {
    final api = ApiClient(
      client: MockClient(handler),
      baseUrl: 'http://backend.test',
    );
    addTearDown(api.close);
    return api;
  }

  test(
    'public GET reads the backend array and optional image defaults',
    () async {
      final api = clientFor((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          jsonEncode([
            {...projectJson, 'project_image_url': null},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final projects = await api.getProjects();
      expect(projects.single.title, 'Portofolio café');
      expect(projects.single.projectImageUrl, '');
      expect(projects.single.year, 2026);
    },
  );

  test(
    'POST sends writable schema fields and token, excluding server fields',
    () async {
      final api = clientFor((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['authorization'], 'Token owner-token');
        expect(request.headers['content-type'], contains('application/json'));
        expect(jsonDecode(request.body), {
          'title': 'Portofolio café',
          'description': 'Proyek dari Django.',
          'category': 'web',
          'year': 2026,
          'project_url': 'https://example.com',
          'project_image_url': '',
        });
        return http.Response(
          jsonEncode(projectJson),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final saved = await api.createProject(
        Project.fromJson(projectJson),
        token: 'owner-token',
      );
      expect(saved.id, projectJson['id']);
      expect(saved.starCount, 2);
    },
  );

  test(
    'login sends JSON credentials and preserves password whitespace',
    () async {
      final api = clientFor((request) async {
        expect(request.url.path, '/api/v1/auth/token/');
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'username': 'owner',
          'password': ' password ',
        });
        return http.Response('{"token":"issued-token"}', 200);
      });
      expect(await api.obtainToken('owner', ' password '), 'issued-token');
    },
  );

  test('logout accepts an empty 204 response', () async {
    final api = clientFor((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.headers['authorization'], 'Token issued-token');
      return http.Response('', 204);
    });
    await api.logout(token: 'issued-token');
  });

  test(
    'HTTP failures retain status without exposing raw server body in UI',
    () async {
      final api = clientFor(
        (_) async => http.Response('<html>server error</html>', 500),
      );
      await expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 500)
              .having(
                (error) => error.userMessage,
                'message',
                isNot(contains('<html>')),
              ),
        ),
      );
    },
  );

  test('malformed login responses do not create a local session', () async {
    final api = clientFor((_) async => http.Response('{"token":null}', 200));
    final auth = AuthState(api);
    addTearDown(auth.dispose);
    await expectLater(auth.login('owner', 'password'), throwsFormatException);
    expect(auth.isLoggedIn, isFalse);
  });

  test('AuthState notifies listeners after successful login', () async {
    final api = clientFor((_) async => http.Response('{"token":"valid"}', 200));
    final auth = AuthState(api);
    addTearDown(auth.dispose);
    var notifications = 0;
    auth.addListener(() => notifications++);
    await auth.login('owner', 'password');
    expect(auth.token, 'valid');
    expect(auth.isLoggedIn, isTrue);
    expect(notifications, 1);
  });

  for (final offline in [false, true]) {
    test(
      'logout clears local token when ${offline ? 'offline' : 'server rejects token'}',
      () async {
        final api = clientFor((_) async {
          if (offline) throw http.ClientException('offline');
          return http.Response('{"detail":"Invalid token."}', 401);
        });
        final auth = AuthState(api, initialToken: 'expired');
        addTearDown(auth.dispose);
        var notifications = 0;
        auth.addListener(() => notifications++);
        await auth.logout();
        expect(auth.token, isNull);
        expect(auth.isLoggedIn, isFalse);
        expect(notifications, 1);
      },
    );
  }
}
