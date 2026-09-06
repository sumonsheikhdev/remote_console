import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/zone_error_capture.dart';

void main() {
  test('captures uncaught zone errors', () async {
    Object? capturedError;
    StackTrace? capturedStackTrace;

    final capture = ZoneErrorCapture(
      onError: (error, stackTrace) {
        capturedError = error;
        capturedStackTrace = stackTrace;
      },
    );

    await capture.run(() async {
      throw StateError('Test zone error');
    });

    expect(capturedError, isA<StateError>());
    expect(capturedStackTrace, isNotNull);
  });

  test('completes normally when no error occurs', () async {
    var executed = false;

    final capture = ZoneErrorCapture(
      onError: (_, __) {
        fail('Error handler should not be called');
      },
    );

    await capture.run(() async {
      executed = true;
    });

    expect(executed, isTrue);
  });
}