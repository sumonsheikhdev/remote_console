import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'console_transport.dart';
import 'console_transport_event.dart';

class WebSocketConsoleTransport implements ConsoleTransport {
  WebSocketConsoleTransport({required this.uri});

  final Uri uri;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;

  final StreamController<ConsoleTransportEvent> _eventsController =
      StreamController<ConsoleTransportEvent>.broadcast();

  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Stream<ConsoleTransportEvent> get events => _eventsController.stream;

  @override
  Future<void> connect() async {
    if (_connected) {
      return;
    }

    final socket = await WebSocket.connect(uri.toString());

    _socket = socket;
    _connected = true;

    _subscription = socket.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );
  }

  @override
  Future<void> send(ConsoleTransportEvent event) async {
    if (!_connected || _socket == null) {
      throw StateError('WebSocket is not connected.');
    }

    _socket!.add(jsonEncode(event.toJson()));
  }

  @override
  Future<void> disconnect() async {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    await socket.close();

    await _subscription?.cancel();

    _subscription = null;
    _socket = null;
    _connected = false;
  }

  void _handleMessage(dynamic message) {
    if (message is! String) {
      return;
    }

    final decoded = jsonDecode(message);

    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final type = decoded['type'];

    if (type is! String) {
      return;
    }

    final payload = decoded['payload'];

    Map<String, Object?>? normalizedPayload;

    if (payload is Map) {
      normalizedPayload = Map<String, Object?>.from(payload);
    }

    final fields = <String, Object?>{...decoded}..remove('type');

    if (decoded.containsKey('payload')) {
      fields.remove('payload');
    }

    _eventsController.add(
      ConsoleTransportEvent(
        type: type,
        payload: normalizedPayload,
        fields: fields.isEmpty ? null : fields,
      ),
    );
  }

  void _handleError(Object error, StackTrace stackTrace) {
    // Connection errors are handled by the transport state.
  }

  void _handleDone() {
    _connected = false;
    _socket = null;
    _subscription = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }
}
