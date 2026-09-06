import '../event/console_event.dart';

class ConsoleRingBuffer {
  ConsoleRingBuffer({
    required this.capacity,
  }) : assert(capacity > 0);

  final int capacity;

  final List<ConsoleEvent> _events = [];

  int get length => _events.length;

  bool get isEmpty => _events.isEmpty;

  bool get isNotEmpty => _events.isNotEmpty;

  void add(ConsoleEvent event) {
    if (_events.length >= capacity) {
      _events.removeAt(0);
    }

    _events.add(event);
  }

  List<ConsoleEvent> snapshot() {
    return List.unmodifiable(_events);
  }

  void clear() {
    _events.clear();
  }
}