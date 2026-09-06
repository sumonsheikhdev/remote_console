import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/flutter_error_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures Flutter errors', () {
    final previous = FlutterError.onError;

    try {
      var previousCalled = false;

      FlutterError.onError = (_) {
        previousCalled = true;
      };

      FlutterErrorDetails? captured;

      final capture = FlutterErrorCapture(
        onError: (details) {
          captured = details;
        },
      );

      capture.install();

      final details = FlutterErrorDetails(
        exception: StateError('Test error'),
        stack: StackTrace.current,
        library: 'Test',
      );

      FlutterError.onError?.call(details);

      expect(captured, isNotNull);
      expect(
        captured!.exception,
        isA<StateError>(),
      );
      expect(previousCalled, isTrue);

      capture.uninstall();
    } finally {
      FlutterError.onError = previous;
    }
  });

  test('does not install twice', () {
    final capture = FlutterErrorCapture(
      onError: (_) {},
    );

    capture.install();
    capture.install();

    capture.uninstall();
  });
}