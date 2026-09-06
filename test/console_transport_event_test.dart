import 'package:flutter_test/flutter_test.dart';

import '../lib/src/transport/console_transport_event.dart';

void main() {
  group('ConsoleTransportEvent', () {
    test(
      'stores event type',
      () {
        const event = ConsoleTransportEvent(
          type: 'test',
        );

        expect(event.type, 'test');
        expect(event.payload, isNull);
      },
    );

    test(
      'stores payload',
      () {
        const event = ConsoleTransportEvent(
          type: 'test',
          payload: {
            'message': 'hello',
            'count': 10,
          },
        );

        expect(
          event.payload,
          {
            'message': 'hello',
            'count': 10,
          },
        );
      },
    );

    test(
      'serializes without payload',
      () {
        const event = ConsoleTransportEvent(
          type: 'test',
        );

        expect(
          event.toJson(),
          {
            'type': 'test',
          },
        );
      },
    );

    test(
      'serializes with payload',
      () {
        const event = ConsoleTransportEvent(
          type: 'test',
          payload: {
            'message': 'hello',
          },
        );

        expect(
          event.toJson(),
          {
            'type': 'test',
            'payload': {
              'message': 'hello',
            },
          },
        );
      },
    );

    test(
      'toString contains event type',
      () {
        const event = ConsoleTransportEvent(
          type: 'session.request',
        );

        expect(
          event.toString(),
          contains('session.request'),
        );
      },
    );
  });
}