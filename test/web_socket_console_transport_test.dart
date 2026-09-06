import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_console/src/transport/console_transport_event.dart';
import 'package:remote_console/src/transport/web_socket_console_transport.dart';

void main() {
  late HttpServer server;
  late Completer<WebSocket> serverSocketCompleter;
  late int port;

  setUp(() async {
    serverSocketCompleter = Completer<WebSocket>();

    server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );

    port = server.port;

    server
        .transform(WebSocketTransformer())
        .listen((socket) {
      if (!serverSocketCompleter.isCompleted) {
        serverSocketCompleter.complete(socket);
      }
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('connects to websocket server', () async {
    final transport = WebSocketConsoleTransport(
      uri: Uri.parse('ws://127.0.0.1:$port'),
    );

    expect(transport.isConnected, isFalse);

    await transport.connect();

    expect(transport.isConnected, isTrue);

    await transport.dispose();
  });

  test('sends transport event', () async {
    final received = <String>[];

    await server.close(force: true);

    server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );

    port = server.port;

    server.transform(WebSocketTransformer()).listen(
      (WebSocket socket) {
        socket.listen((message) {
          received.add(message as String);
        });
      },
    );

    final transport = WebSocketConsoleTransport(
      uri: Uri.parse('ws://127.0.0.1:$port'),
    );

    await transport.connect();

    await transport.send(
      const ConsoleTransportEvent(
        type: 'ping',
      ),
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 50),
    );

    expect(received, hasLength(1));

    expect(
      jsonDecode(received.single),
      {
        'type': 'ping',
      },
    );

    await transport.dispose();
  });

test('receives transport event', () async {
  final transport = WebSocketConsoleTransport(
    uri: Uri.parse('ws://127.0.0.1:$port'),
  );

  await transport.connect();

  final serverSocket = await serverSocketCompleter.future;

  // Subscribe BEFORE the server sends anything.
  final eventFuture = transport.events.first;

  serverSocket.add(
    jsonEncode({
      'type': 'ping',
      'payload': {
        'value': 123,
      },
    }),
  );

  final event = await eventFuture;

  expect(event.type, 'ping');
  expect(event.payload, {
    'value': 123,
  });

  await transport.disconnect();
});
}