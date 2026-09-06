import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/capture/print_capture.dart';

void main() {
  test('captures print output', () async {
    final captured = <String>[];

    final capture = PrintCapture(
      onPrint: captured.add,
    );

    await capture.run(() {
      print('hello remote console');
    });

    expect(captured, ['hello remote console']);
  });

  test('captures multiple print calls', () async {
    final captured = <String>[];

    final capture = PrintCapture(
      onPrint: captured.add,
    );

    await capture.run(() async {
      print('first');
      print('second');
      print('third');
    });

    expect(
      captured,
      ['first', 'second', 'third'],
    );
  });

  test('does not capture prints outside the zone', () {
    final captured = <String>[];

    final capture = PrintCapture(
      onPrint: captured.add,
    );

    print('outside');

    expect(captured, isEmpty);
  });
}