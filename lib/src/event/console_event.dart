

import 'package:remote_console/remote_console.dart';

class ConsoleEvent {
  const ConsoleEvent({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
    this.metadata,
    this.error,
    this.stackTrace,
  });

  final String id;
  final DateTime timestamp;
  final ConsoleEventLevel level;
  final String source;
  final String message;

  final Map<String, Object?>? metadata;

  final Object? error;
  final StackTrace? stackTrace;

  bool get isError => level == ConsoleEventLevel.error;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'level': level.name,
      'source': source,
      'message': message,
      if (metadata != null) 'metadata': metadata,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  @override
  String toString() {
    return 'ConsoleEvent('
        'id: $id, '
        'level: ${level.name}, '
        'source: $source, '
        'message: $message'
        ')';
  }
}

