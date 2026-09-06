import 'dart:math';

import 'installation_storage.dart';

class InstallationIdentity {
  InstallationIdentity({
    required InstallationStorage storage,
  }) : _storage = storage;

  final InstallationStorage _storage;

  String? _installationId;

  String? get value => _installationId;

  Future<String> loadOrCreate() async {
    final existing = await _storage.read();

    if (existing != null && existing.isNotEmpty) {
      _installationId = existing;
      return existing;
    }

    final installationId = _generateId();

    await _storage.write(installationId);

    _installationId = installationId;

    return installationId;
  }

  Future<void> delete() async {
    await _storage.delete();

    _installationId = null;
  }

  String _generateId() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );

    return bytes
        .map(
          (byte) => byte.toRadixString(16).padLeft(2, '0'),
        )
        .join();
  }
}