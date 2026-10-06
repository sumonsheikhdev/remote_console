import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:remote_console/src/buffer/console_ring_buffer.dart';
import 'package:remote_console/src/capture/console_capture.dart';
import 'package:remote_console/src/core/remote_console_config.dart';
import 'package:remote_console/src/core/remote_console_state.dart';
import 'package:remote_console/src/event/console_event.dart';
import 'package:remote_console/src/event/console_event_id.dart';
import 'package:remote_console/src/event/console_event_level.dart';
import 'package:remote_console/src/identity/installation_identity.dart';
import 'package:remote_console/src/identity/installation_storage.dart';
import 'package:remote_console/src/session/debug_session.dart';

import 'package:remote_console/src/transport/console_transport.dart';
import 'package:remote_console/src/transport/console_transport_event.dart';
import 'package:remote_console/src/transport/web_socket_console_transport.dart';

class RemoteConsoleEngine {
  RemoteConsoleEngine({
    required RemoteConsoleConfig config,
    required InstallationStorage installationStorage,
  }) : _config = config,
       _buffer = ConsoleRingBuffer(capacity: config.maxBufferedEvents),
       _identity = InstallationIdentity(storage: installationStorage);

  final RemoteConsoleConfig _config;
  final ConsoleRingBuffer _buffer;
  final InstallationIdentity _identity;

  DebugSession? _debugSession;

  ConsoleTransport? _transport;

  StreamSubscription<ConsoleTransportEvent>? _transportSubscription;

  String? get installationId => _identity.value;

  DebugSession? get debugSession => _debugSession;

  RemoteConsoleState _state = RemoteConsoleState.uninitialized;

  RemoteConsoleState get state => _state;

  RemoteConsoleConfig get config => _config;

  List<ConsoleEvent> get recentEvents => _buffer.snapshot();

  int get bufferedEventCount => _buffer.length;

  bool get isDebugging => _state == RemoteConsoleState.debugging;

  bool get isCapturing => _capture.isInstalled;

  bool get isConnected => _transport?.isConnected ?? false;

  late final ConsoleCapture _capture = ConsoleCapture(
    onEvent:
        ({
          required String source,
          required String message,
          Object? error,
          StackTrace? stackTrace,
        }) {
          record(
            source: source,
            message: message,
            error: error,
            stackTrace: stackTrace,
          );
        },
  );

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_state != RemoteConsoleState.uninitialized) {
      return;
    }

    _state = RemoteConsoleState.initializing;

    debugPrint('[RemoteConsole] Initializing...');

    await _identity.loadOrCreate();

    debugPrint('[RemoteConsole] Installation ID: ${_identity.value}');

    if (_config.enabled) {
      _capture.install();

      debugPrint('[RemoteConsole] Console capture enabled.');
    }

    final serverUrl = _config.serverUrl;

    if (serverUrl != null && serverUrl.isNotEmpty) {
      debugPrint('[RemoteConsole] Connecting to: $serverUrl');

      await _connectTransport();

      debugPrint('[RemoteConsole] WebSocket connected: $isConnected');
    } else {
      debugPrint('[RemoteConsole] No server URL configured.');
    }

    _state = RemoteConsoleState.ready;

    debugPrint('[RemoteConsole] Ready. Installation ID: ${_identity.value}');
  }

  // ---------------------------------------------------------------------------
  // WebSocket
  // ---------------------------------------------------------------------------

  Future<void> _connectTransport() async {
    final serverUrl = _config.serverUrl;

    if (serverUrl == null || serverUrl.isEmpty) {
      return;
    }

    final installationId = _identity.value;

    if (installationId == null) {
      return;
    }

    final transport = WebSocketConsoleTransport(uri: Uri.parse(serverUrl));

    _transport = transport;

    _transportSubscription = transport.events.listen(_handleTransportEvent);

    try {
      await transport.connect();

      await transport.send(
        ConsoleTransportEvent(
          type: 'installation.register',
          fields: {'installationId': installationId},
        ),
      );
    } catch (_) {
      await _disconnectTransport();
    }
  }

  void _handleTransportEvent(ConsoleTransportEvent event) {
    switch (event.type) {
      case 'connection.ready':
        debugPrint('[RemoteConsole] Server connection ready.');
        break;

      case 'installation.registered':
        debugPrint(
          '[RemoteConsole] Installation registered: '
          '${event.fields?['installationId']}',
        );
        break;

      case 'error':
        debugPrint(
          '[RemoteConsole] Server error: '
          '${event.fields}',
        );
        break;
    }
  }

  Future<void> _disconnectTransport() async {
    await _transportSubscription?.cancel();

    _transportSubscription = null;

    await _transport?.disconnect();

    _transport = null;
  }

  // ---------------------------------------------------------------------------
  // Recording
  // ---------------------------------------------------------------------------

  ConsoleEvent record({
    ConsoleEventLevel level = ConsoleEventLevel.info,
    required String source,
    required String message,
    Map<String, Object?>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final event = ConsoleEvent(
      id: ConsoleEventId.generate(),
      timestamp: DateTime.now(),
      level: level,
      source: source,
      message: message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );

    if (_config.enabled) {
      _buffer.add(event);
    }

    _sendEvent(event);

    return event;
  }

  void _sendEvent(ConsoleEvent event) {
    final transport = _transport;

    if (transport == null || !transport.isConnected) {
      return;
    }

    unawaited(
      transport.send(
        ConsoleTransportEvent(type: 'console.event', payload: event.toJson()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Capture
  // ---------------------------------------------------------------------------

  FutureOr<void> runCaptured(FutureOr<void> Function() body) {
    return _capture.runZoned(body);
  }

  // ---------------------------------------------------------------------------
  // Developer mode
  // ---------------------------------------------------------------------------

  void enableDeveloperMode() {
    if (_state != RemoteConsoleState.ready) {
      return;
    }

    _state = RemoteConsoleState.developerMode;
  }

  void disableDeveloperMode() {
    if (_state != RemoteConsoleState.developerMode) {
      return;
    }

    _state = RemoteConsoleState.ready;
  }

  // ---------------------------------------------------------------------------
  // Debugging
  // ---------------------------------------------------------------------------

  void startDebugging() {
    if (_state != RemoteConsoleState.developerMode) {
      return;
    }

    final installationId = _identity.value;

    if (installationId == null) {
      return;
    }

    final startedAt = DateTime.now();

    _debugSession = DebugSession(
      sessionId: ConsoleEventId.generate(),
      installationId: installationId,
      startedAt: startedAt,
    );

    _state = RemoteConsoleState.debugging;
  }

  void stopDebugging() {
    if (_state != RemoteConsoleState.debugging) {
      return;
    }

    _debugSession = null;

    _state = RemoteConsoleState.developerMode;
  }

  // ---------------------------------------------------------------------------
  // Buffer
  // ---------------------------------------------------------------------------

  void clearBuffer() {
    _buffer.clear();
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    _capture.uninstall();

    await _disconnectTransport();

    _debugSession = null;

    _buffer.clear();

    _state = RemoteConsoleState.stopped;
  }
}
