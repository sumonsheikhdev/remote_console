import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/core/remote_console_config.dart';
import 'package:remote_console/src/core/remote_console_engine.dart';
import 'package:remote_console/src/core/remote_console_state.dart';
import 'package:remote_console/src/event/console_event_level.dart';

import 'installation_identity_test.dart';

void main() {
  group('RemoteConsoleEngine', () {
    test('starts uninitialized', () {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      expect(engine.state, RemoteConsoleState.uninitialized);
    });

    test('initializes successfully', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      expect(engine.state, RemoteConsoleState.ready);
    });

    test('records event into buffer', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      final event = engine.record(
        source: 'MediaNetwork',
        message: 'REQUEST',
        metadata: {'rangeStart': 0, 'rangeEnd': 2097151},
      );

      expect(engine.bufferedEventCount, 1);
      expect(engine.recentEvents.first.id, event.id);
      expect(engine.recentEvents.first.source, 'MediaNetwork');
    });

    test('records errors with stack trace', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      final stackTrace = StackTrace.current;

      final event = engine.record(
        level: ConsoleEventLevel.error,
        source: 'PlayerManager',
        message: 'SEEK FAILED',
        error: StateError('No element'),
        stackTrace: stackTrace,
      );

      expect(event.isError, isTrue);
      expect(event.error, isA<StateError>());
      expect(event.stackTrace, stackTrace);
    });

    test('buffer respects configured capacity', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(maxBufferedEvents: 3),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.record(source: 'Test', message: '1');

      engine.record(source: 'Test', message: '2');

      engine.record(source: 'Test', message: '3');

      engine.record(source: 'Test', message: '4');

      expect(engine.bufferedEventCount, 3);

      expect(engine.recentEvents.map((event) => event.message), [
        '2',
        '3',
        '4',
      ]);
    });

    test('initialization installs console capture', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      expect(engine.isCapturing, isFalse);

      await engine.initialize();

      expect(engine.isCapturing, isTrue);

      await engine.dispose();
    });

    test('captured print is recorded in the buffer', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      try {
        await engine.runCaptured(() async {
          print('hello from engine');
        });

        expect(engine.bufferedEventCount, 1);

        final event = engine.recentEvents.single;

        expect(event.source, 'print');
        expect(event.message, 'hello from engine');
        expect(event.level, ConsoleEventLevel.info);
      } finally {
        await engine.dispose();
      }
    });

    test('captured debugPrint is recorded in the buffer', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      try {
        debugPrint('hello from debugPrint');

        expect(engine.bufferedEventCount, 1);

        final event = engine.recentEvents.single;

        expect(event.source, 'debugPrint');
        expect(event.message, 'hello from debugPrint');
      } finally {
        await engine.dispose();
      }
    });

    test('dispose removes console capture', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      expect(engine.isCapturing, isTrue);

      await engine.dispose();

      expect(engine.isCapturing, isFalse);
      expect(engine.state, RemoteConsoleState.stopped);
    });

    test('developer mode changes state', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.enableDeveloperMode();

      expect(engine.state, RemoteConsoleState.developerMode);
    });

    test('debugging requires developer mode', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.startDebugging();

      expect(engine.state, RemoteConsoleState.ready);
    });

    test('starts and stops debugging', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.enableDeveloperMode();
      engine.startDebugging();

      expect(engine.state, RemoteConsoleState.debugging);

      engine.stopDebugging();

      expect(engine.state, RemoteConsoleState.developerMode);
    });

    test('clearBuffer removes recorded events', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.record(source: 'Test', message: 'Hello');

      expect(engine.bufferedEventCount, 1);

      engine.clearBuffer();

      expect(engine.bufferedEventCount, 0);
      expect(engine.recentEvents, isEmpty);
    });

    test('disabled configuration does not buffer events', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(enabled: false),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      final event = engine.record(source: 'Test', message: 'Should not buffer');

      expect(event.message, 'Should not buffer');
      expect(engine.bufferedEventCount, 0);
    });

    test('cannot start debugging without developer mode', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.startDebugging();

      expect(engine.state, RemoteConsoleState.ready);

      expect(engine.debugSession, isNull);

      await engine.dispose();
    });

    test('startDebugging creates a debug session', () async {
      final engine = RemoteConsoleEngine(
        config: const RemoteConsoleConfig(),
        installationStorage: MemoryInstallationStorage(),
      );

      await engine.initialize();

      engine.enableDeveloperMode();
      engine.startDebugging();

      expect(engine.state, RemoteConsoleState.debugging);

      expect(engine.debugSession, isNotNull);
      expect(engine.debugSession!.installationId, isNotEmpty);

      expect(engine.debugSession!.sessionId, isNotEmpty);

      await engine.dispose();
    });

    test(
  'stopDebugging removes the debug session',
  () async {
    final engine = RemoteConsoleEngine(
      config: const RemoteConsoleConfig(),
      installationStorage: MemoryInstallationStorage(),
    );

    await engine.initialize();

    engine.enableDeveloperMode();
    engine.startDebugging();

    expect(engine.debugSession, isNotNull);

    engine.stopDebugging();

    expect(
      engine.state,
      RemoteConsoleState.developerMode,
    );

    expect(engine.debugSession, isNull);

    await engine.dispose();
  },
);test(
  'dispose removes the debug session',
  () async {
    final engine = RemoteConsoleEngine(
      config: const RemoteConsoleConfig(),
      installationStorage: MemoryInstallationStorage(),
    );

    await engine.initialize();

    engine.enableDeveloperMode();
    engine.startDebugging();

    expect(engine.debugSession, isNotNull);

    await engine.dispose();

    expect(engine.debugSession, isNull);
    expect(
      engine.state,
      RemoteConsoleState.stopped,
    );
  },
);
  });
}
