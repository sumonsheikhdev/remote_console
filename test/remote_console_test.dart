
import 'package:flutter_test/flutter_test.dart';

import 'package:remote_console/src/core/remote_console.dart';
import 'package:remote_console/src/core/remote_console_state.dart';

void main() {
  group('RemoteConsole', () {
    test(
      'initializes through the public API',
      () async {
        final console = RemoteConsole();

        expect(
          console.state,
          RemoteConsoleState.uninitialized,
        );

        await console.initialize();

        expect(
          console.state,
          RemoteConsoleState.ready,
        );

        expect(
          console.installationId,
          isNotNull,
        );

        expect(
          console.installationId,
          isNotEmpty,
        );

        await console.dispose();
      },
    );

    test(
      'exposes the installationId',
      () async {
        final console = RemoteConsole();

        await console.initialize();

        expect(
          console.installationId,
          isNotNull,
        );

        expect(
          console.installationId,
          isNotEmpty,
        );

        await console.dispose();
      },
    );

    test(
      'controls developer mode',
      () async {
        final console = RemoteConsole();

        await console.initialize();

        console.enableDeveloperMode();

        expect(
          console.state,
          RemoteConsoleState.developerMode,
        );

        console.disableDeveloperMode();

        expect(
          console.state,
          RemoteConsoleState.ready,
        );

        await console.dispose();
      },
    );

    test(
      'controls debugging session',
      () async {
        final console = RemoteConsole();

        await console.initialize();

        console.enableDeveloperMode();
        console.startDebugging();

        expect(
          console.state,
          RemoteConsoleState.debugging,
        );

        expect(
          console.debugSession,
          isNotNull,
        );

        console.stopDebugging();

        expect(
          console.state,
          RemoteConsoleState.developerMode,
        );

        expect(
          console.debugSession,
          isNull,
        );

        await console.dispose();
      },
    );

    test(
      'exposes recent events',
      () async {
        final console = RemoteConsole();

        await console.initialize();

        console.record(
          source: 'test',
          message: 'hello',
        );

        expect(
          console.recentEvents,
          hasLength(1),
        );

        expect(
          console.recentEvents.first.message,
          'hello',
        );

        await console.dispose();
      },
    );
  });
}
