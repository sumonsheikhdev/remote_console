abstract interface class InstallationStorage {
  Future<String?> read();

  Future<void> write(String installationId);

  Future<void> delete();
}