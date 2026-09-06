import 'dart:async';

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
String? get installationId => _identity.value;
  DebugSession? get debugSession => _debugSession;
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

  RemoteConsoleState _state = RemoteConsoleState.uninitialized;

  RemoteConsoleState get state => _state;

  RemoteConsoleConfig get config => _config;

  List<ConsoleEvent> get recentEvents => _buffer.snapshot();

  int get bufferedEventCount => _buffer.length;

  bool get isDebugging => _state == RemoteConsoleState.debugging;

  bool get isCapturing => _capture.isInstalled;

  Future<void> initialize() async {
    if (_state != RemoteConsoleState.uninitialized) {
      return;
    }

    _state = RemoteConsoleState.initializing;

    await _identity.loadOrCreate();

    if (_config.enabled) {
      _capture.install();
    }

    _state = RemoteConsoleState.ready;
  }

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

    return event;
  }

  FutureOr<void> runCaptured(FutureOr<void> Function() body) {
    return _capture.runZoned(body);
  }

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

  void clearBuffer() {
    _buffer.clear();
  }

  Future<void> dispose() async {
    _capture.uninstall();
    _debugSession = null;
    _buffer.clear();
    _state = RemoteConsoleState.stopped;
  }
}
