class DebugSession {
  const DebugSession({
    required this.sessionId,
    required this.installationId,
    required this.startedAt,
    this.expiresAt,
  });

  final String sessionId;
  final String installationId;
  final DateTime startedAt;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiration = expiresAt;

    if (expiration == null) {
      return false;
    }

    return DateTime.now().isAfter(expiration);
  }

  Map<String, Object?> toJson() {
    return {
      'sessionId': sessionId,
      'installationId': installationId,
      'startedAt': startedAt.toUtc().toIso8601String(),
      if (expiresAt != null)
        'expiresAt': expiresAt!.toUtc().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DebugSession('
        'sessionId: $sessionId, '
        'installationId: $installationId'
        ')';
  }
}