import 'console_event.dart';

abstract interface class ConsoleEventSink {
  void add(ConsoleEvent event);
}