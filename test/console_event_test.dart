import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/remote_console.dart';

void main() {
  test('creates a console event', () {
    final event = ConsoleEvent(
      id: 'event-1',
      timestamp: DateTime.utc(2026, 1, 1),
      level: ConsoleEventLevel.info,
      source: 'MediaNetwork',
      message: 'REQUEST',
      metadata: {
        'mediaId': 'abc123',
        'rangeStart': 0,
        'rangeEnd': 2097151,
      },
    );

    expect(event.id, 'event-1');
    expect(event.level, ConsoleEventLevel.info);
    expect(event.source, 'MediaNetwork');
    expect(event.message, 'REQUEST');
    expect(event.metadata?['mediaId'], 'abc123');
  });

  test('serializes event to JSON-compatible map', () {
    final event = ConsoleEvent(
      id: 'event-1',
      timestamp: DateTime.utc(2026, 1, 1),
      level: ConsoleEventLevel.error,
      source: 'PlayerManager',
      message: 'SEEK FAILED',
      error: StateError('No element'),
      stackTrace: StackTrace.current,
    );

    final json = event.toJson();

    expect(json['id'], 'event-1');
    expect(json['level'], 'error');
    expect(json['source'], 'PlayerManager');
    expect(json['message'], 'SEEK FAILED');
    expect(json['error'], contains('No element'));
    expect(json['stackTrace'], isNotNull);
  });
}