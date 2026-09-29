import 'installation_storage.dart';

class MemoryInstallationStorage
    implements InstallationStorage {
  String? _installationId;

  @override
  Future<String?> read() async {
    return _installationId;
  }

  @override
  Future<void> write(String installationId) async {
    _installationId = installationId;
  }

  @override
  Future<void> delete() async {
    _installationId = null;
  }
}