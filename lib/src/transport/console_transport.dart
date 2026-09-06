import 'console_transport_event.dart';

abstract interface class ConsoleTransport {
  bool get isConnected;

  Future<void> connect();

  Future<void> send(ConsoleTransportEvent event);

  Stream<ConsoleTransportEvent> get events;

  Future<void> disconnect();
}