import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/transport/console_transport.dart';
import '../lib/src/transport/console_transport_event.dart';

class FakeConsoleTransport implements ConsoleTransport {
  final StreamController<ConsoleTransportEvent> _controller =
      StreamController<ConsoleTransportEvent>.broadcast();

  final List<ConsoleTransportEvent> sentEvents = [];

  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Stream<ConsoleTransportEvent> get events => _controller.stream;

  @override
  Future<void> connect() async {
    _connected = true;
  }

  @override
  Future<void> send(ConsoleTransportEvent event) async {
    if (!_connected) {
      throw StateError('Transport is not connected');
    }

    sentEvents.add(event);
  }

  void emit(ConsoleTransportEvent event) {
    _controller.add(event);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('ConsoleTransport', () {
    test(
      'starts disconnected',
      () async {
        final transport = FakeConsoleTransport();

        expect(transport.isConnected, isFalse);

        await transport.dispose();
      },
    );

    test(
      'connect changes connection state',
      () async {
        final transport = FakeConsoleTransport();

        await transport.connect();

        expect(transport.isConnected, isTrue);

        await transport.dispose();
      },
    );

    test(
      'disconnect changes connection state',
      () async {
        final transport = FakeConsoleTransport();

        await transport.connect();
        await transport.disconnect();

        expect(transport.isConnected, isFalse);

        await transport.dispose();
      },
    );

    test(
      'send delivers an event',
      () async {
        final transport = FakeConsoleTransport();

        await transport.connect();

        const event = ConsoleTransportEvent(
          type: 'test',
          payload: {
            'message': 'hello',
          },
        );

        await transport.send(event);

        expect(
          transport.sentEvents,
          [event],
        );

        await transport.dispose();
      },
    );

    test(
      'send fails when disconnected',
      () async {
        final transport = FakeConsoleTransport();

        const event = ConsoleTransportEvent(
          type: 'test',
        );

        expect(
          () => transport.send(event),
          throwsA(isA<StateError>()),
        );

        await transport.dispose();
      },
    );

    test(
      'events receives incoming events',
      () async {
        final transport = FakeConsoleTransport();

        final future = expectLater(
          transport.events,
          emits(
            const ConsoleTransportEvent(
              type: 'incoming',
            ),
          ),
        );

        transport.emit(
          const ConsoleTransportEvent(
            type: 'incoming',
          ),
        );

        await future;
        await transport.dispose();
      },
    );
  });
}