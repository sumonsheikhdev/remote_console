import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/developer/developer_mode.dart';


void main() {
  group('DeveloperMode', () {
    test(
      'is disabled by default',
      () {
        final developerMode = DeveloperMode();

        expect(developerMode.isEnabled, isFalse);
      },
    );

    test(
      'enable activates developer mode',
      () {
        final developerMode = DeveloperMode();

        developerMode.enable();

        expect(developerMode.isEnabled, isTrue);
      },
    );

    test(
      'disable deactivates developer mode',
      () {
        final developerMode = DeveloperMode();

        developerMode.enable();
        developerMode.disable();

        expect(developerMode.isEnabled, isFalse);
      },
    );

    test(
      'repeated enable keeps developer mode enabled',
      () {
        final developerMode = DeveloperMode();

        developerMode.enable();
        developerMode.enable();

        expect(developerMode.isEnabled, isTrue);
      },
    );

    test(
      'repeated disable keeps developer mode disabled',
      () {
        final developerMode = DeveloperMode();

        developerMode.disable();
        developerMode.disable();

        expect(developerMode.isEnabled, isFalse);
      },
    );
  });
}