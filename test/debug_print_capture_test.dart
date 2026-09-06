import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/debug_print_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures debugPrint output', () {
    final previous = debugPrint;

    try {
      final captured = <String>[];

      final capture = DebugPrintCapture(
        onPrint: captured.add,
      );

      capture.install();

      debugPrint('hello debugPrint');

      expect(
        captured,
        ['hello debugPrint'],
      );

      capture.uninstall();
    } finally {
      debugPrint = previous;
    }
  });

  test('does not install twice', () {
    final previous = debugPrint;

    try {
      final capture = DebugPrintCapture(
        onPrint: (_) {},
      );

      capture.install();
      capture.install();

      capture.uninstall();
    } finally {
      debugPrint = previous;
    }
  });
}