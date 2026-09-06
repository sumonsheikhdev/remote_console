import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/buffer/console_ring_buffer.dart';
import 'package:remote_console/src/event/console_event.dart';
import 'package:remote_console/src/event/console_event_level.dart';

ConsoleEvent event(String id) {
  return ConsoleEvent(
    id: id,
    timestamp: DateTime.now(),
    level: ConsoleEventLevel.info,
    source: 'Test',
    message: id,
  );
}

void main() {
  test('stores events up to capacity', () {
    final buffer = ConsoleRingBuffer(capacity: 3);

    buffer.add(event('1'));
    buffer.add(event('2'));
    buffer.add(event('3'));

    expect(buffer.length, 3);
    expect(
      buffer.snapshot().map((e) => e.id),
      ['1', '2', '3'],
    );
  });

  test('removes oldest event when capacity is exceeded', () {
    final buffer = ConsoleRingBuffer(capacity: 3);

    buffer.add(event('1'));
    buffer.add(event('2'));
    buffer.add(event('3'));
    buffer.add(event('4'));

    expect(buffer.length, 3);
    expect(
      buffer.snapshot().map((e) => e.id),
      ['2', '3', '4'],
    );
  });

  test('clear removes all events', () {
    final buffer = ConsoleRingBuffer(capacity: 3);

    buffer.add(event('1'));
    buffer.add(event('2'));

    buffer.clear();

    expect(buffer.isEmpty, isTrue);
    expect(buffer.length, 0);
  });

  test('snapshot cannot modify the buffer', () {
    final buffer = ConsoleRingBuffer(capacity: 3);

    buffer.add(event('1'));

    final snapshot = buffer.snapshot();

    expect(
      () => snapshot.add(event('2')),
      throwsUnsupportedError,
    );

    expect(buffer.length, 1);
  });
}