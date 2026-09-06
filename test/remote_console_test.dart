import 'package:flutter_test/flutter_test.dart';

import 'package:remote_console/src/core/remote_console.dart';
import 'package:remote_console/src/core/remote_console_state.dart';
import 'package:remote_console/src/identity/installation_storage.dart';
class MemoryInstallationStorage implements InstallationStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String installationId) async {
    value = installationId;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

void main() {
  group('RemoteConsole', () {
    test(
      'initializes through the public API',
      () async {
        final console = RemoteConsole(
          installationStorage: MemoryInstallationStorage(),
        );

        expect(
          console.state,
          RemoteConsoleState.uninitialized,
        );

        await console.initialize();

        expect(
          console.state,
          RemoteConsoleState.ready,
        );

        expect(console.installationId, isNotNull);

        await console.dispose();
      },
    );

    test(
      'exposes the installationId',
      () async {
        final storage = MemoryInstallationStorage();

        final console = RemoteConsole(
          installationStorage: storage,
        );

        await console.initialize();

        expect(
          console.installationId,
          storage.value,
        );

        await console.dispose();
      },
    );

    test(
      'controls developer mode',
      () async {
        final console = RemoteConsole(
          installationStorage: MemoryInstallationStorage(),
        );

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
        final console = RemoteConsole(
          installationStorage: MemoryInstallationStorage(),
        );

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
        final console = RemoteConsole(
          installationStorage: MemoryInstallationStorage(),
        );

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