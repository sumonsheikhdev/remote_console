
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/identity/installation_identity.dart';
import 'package:remote_console/src/identity/installation_storage.dart';
class MemoryInstallationStorage
    implements InstallationStorage {
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
  test('creates and persists installation ID', () async {
    final storage = MemoryInstallationStorage();

    final identity = InstallationIdentity(
      storage: storage,
    );

    final installationId = await identity.loadOrCreate();

    expect(installationId, isNotEmpty);
    expect(identity.value, installationId);
    expect(storage.value, installationId);
  });

  test('loads existing installation ID', () async {
    final storage = MemoryInstallationStorage()
      ..value = 'existing-installation-id';

    final identity = InstallationIdentity(
      storage: storage,
    );

    final installationId = await identity.loadOrCreate();

    expect(
      installationId,
      'existing-installation-id',
    );

    expect(identity.value, installationId);
  });

  test('returns the same ID on repeated loads', () async {
    final storage = MemoryInstallationStorage();

    final identity = InstallationIdentity(
      storage: storage,
    );

    final first = await identity.loadOrCreate();
    final second = await identity.loadOrCreate();

    expect(second, first);
  });

  test('generated installation ID is 32 hexadecimal characters', () async {
    final storage = MemoryInstallationStorage();

    final identity = InstallationIdentity(
      storage: storage,
    );

    final installationId = await identity.loadOrCreate();

    expect(installationId, hasLength(32));
    expect(
      RegExp(r'^[0-9a-f]{32}$').hasMatch(installationId),
      isTrue,
    );
  });

  test('delete removes the installation ID', () async {
    final storage = MemoryInstallationStorage();

    final identity = InstallationIdentity(
      storage: storage,
    );

    await identity.loadOrCreate();
    await identity.delete();

    expect(identity.value, isNull);
    expect(storage.value, isNull);
  });

  test('creates a new ID after deletion', () async {
    final storage = MemoryInstallationStorage();

    final identity = InstallationIdentity(
      storage: storage,
    );

    final first = await identity.loadOrCreate();

    await identity.delete();

    final second = await identity.loadOrCreate();

    expect(second, isNot(first));
    expect(second, hasLength(32));
  });
}

