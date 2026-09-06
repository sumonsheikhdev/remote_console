import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/console_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures print output', () async {
    final events = <Map<String, Object?>>[];

    final capture = ConsoleCapture(
      onEvent: ({
        required source,
        required message,
        error,
        stackTrace,
      }) {
        events.add({
          'source': source,
          'message': message,
          'error': error,
          'stackTrace': stackTrace,
        });
      },
    );

    capture.install();

    try {
      await capture.runZoned(() {
        print('hello');
      });

      expect(events.length, 1);
      expect(events.first['source'], 'print');
      expect(events.first['message'], 'hello');
    } finally {
      capture.uninstall();
    }
  });

  test('captures debugPrint output', () {
    final events = <Map<String, Object?>>[];

    final capture = ConsoleCapture(
      onEvent: ({
        required source,
        required message,
        error,
        stackTrace,
      }) {
        events.add({
          'source': source,
          'message': message,
          'error': error,
          'stackTrace': stackTrace,
        });
      },
    );

    capture.install();

    try {
      debugPrint('hello debug');

      expect(events.length, 1);
      expect(events.first['source'], 'debugPrint');
      expect(events.first['message'], 'hello debug');
    } finally {
      capture.uninstall();
    }
  });

  test('captures Flutter errors', () {
    final events = <Map<String, Object?>>[];

    final capture = ConsoleCapture(
      onEvent: ({
        required source,
        required message,
        error,
        stackTrace,
      }) {
        events.add({
          'source': source,
          'message': message,
          'error': error,
          'stackTrace': stackTrace,
        });
      },
    );

    capture.install();

    try {
      FlutterError.onError?.call(
        FlutterErrorDetails(
          exception: StateError('flutter failure'),
          stack: StackTrace.current,
        ),
      );

      expect(events.length, 1);
      expect(events.first['source'], 'flutter');
      expect(events.first['error'], isA<StateError>());
      expect(events.first['stackTrace'], isNotNull);
    } finally {
      capture.uninstall();
    }
  });

  test('captures zone errors', () async {
    final events = <Map<String, Object?>>[];

    final capture = ConsoleCapture(
      onEvent: ({
        required source,
        required message,
        error,
        stackTrace,
      }) {
        events.add({
          'source': source,
          'message': message,
          'error': error,
          'stackTrace': stackTrace,
        });
      },
    );

    capture.install();

    try {
      await capture.runZoned(() async {
        throw StateError('zone failure');
      });

      expect(events.length, 1);
      expect(events.first['source'], 'zone');
      expect(events.first['error'], isA<StateError>());
      expect(events.first['stackTrace'], isNotNull);
    } finally {
      capture.uninstall();
    }
  });
}