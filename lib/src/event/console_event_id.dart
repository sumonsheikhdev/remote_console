import 'dart:math';

class ConsoleEventId {
  ConsoleEventId._();

  static final Random _random = Random.secure();

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    final random = _random.nextInt(1 << 32);

    return '$timestamp-${random.toRadixString(16)}';
  }
}