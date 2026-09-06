import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/session/debug_session.dart';


void main() {
  group('DebugSession', () {
    test(
      'stores session information',
      () {
        final startedAt = DateTime(2026, 9, 6, 12);

        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: startedAt,
        );

        expect(session.sessionId, 'session-1');
        expect(session.installationId, 'installation-1');
        expect(session.startedAt, startedAt);
        expect(session.expiresAt, isNull);
      },
    );

    test(
      'session without expiration is not expired',
      () {
        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: DateTime.now(),
        );

        expect(session.isExpired, isFalse);
      },
    );

    test(
      'session with future expiration is not expired',
      () {
        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: DateTime.now(),
          expiresAt: DateTime.now().add(
            const Duration(hours: 1),
          ),
        );

        expect(session.isExpired, isFalse);
      },
    );

    test(
      'session with past expiration is expired',
      () {
        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: DateTime.now().subtract(
            const Duration(hours: 2),
          ),
          expiresAt: DateTime.now().subtract(
            const Duration(hours: 1),
          ),
        );

        expect(session.isExpired, isTrue);
      },
    );

    test(
      'toJson serializes session',
      () {
        final startedAt = DateTime.utc(2026, 9, 6, 12);
        final expiresAt = DateTime.utc(2026, 9, 6, 13);

        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: startedAt,
          expiresAt: expiresAt,
        );

        expect(
          session.toJson(),
          {
            'sessionId': 'session-1',
            'installationId': 'installation-1',
            'startedAt': '2026-09-06T12:00:00.000Z',
            'expiresAt': '2026-09-06T13:00:00.000Z',
          },
        );
      },
    );

    test(
      'toString contains session identifiers',
      () {
        final session = DebugSession(
          sessionId: 'session-1',
          installationId: 'installation-1',
          startedAt: DateTime.now(),
        );

        expect(
          session.toString(),
          contains('session-1'),
        );

        expect(
          session.toString(),
          contains('installation-1'),
        );
      },
    );
  });
}