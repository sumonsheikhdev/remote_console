import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/uncaught_error_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures uncaught errors', () {
    final previous = PlatformDispatcher.instance.onError;

    try {
      var previousCalled = false;

      PlatformDispatcher.instance.onError = (_, __) {
        previousCalled = true;
        return true;
      };

      Object? capturedError;
      StackTrace? capturedStackTrace;

      final capture = UncaughtErrorCapture(
        onError: (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
          return false;
        },
      );

      capture.install();

      final error = StateError('Test async error');
      final stackTrace = StackTrace.current;

      final handled =
          PlatformDispatcher.instance.onError!(error, stackTrace);

      expect(capturedError, same(error));
      expect(capturedStackTrace, same(stackTrace));
      expect(previousCalled, isTrue);
      expect(handled, isTrue);

      capture.uninstall();
    } finally {
      PlatformDispatcher.instance.onError = previous;
    }
  });

  test('does not install twice', () {
    final capture = UncaughtErrorCapture(
      onError: (_, __) => false,
    );

    capture.install();
    capture.install();

    capture.uninstall();
  });
}