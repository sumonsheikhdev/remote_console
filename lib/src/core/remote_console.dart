import 'dart:async';

import 'package:remote_console/src/core/remote_console_config.dart';
import 'package:remote_console/src/core/remote_console_engine.dart';
import 'package:remote_console/src/core/remote_console_state.dart';
import 'package:remote_console/src/event/console_event.dart';
import 'package:remote_console/src/event/console_event_level.dart';

import 'package:remote_console/src/identity/memory_installation_storage.dart';
import 'package:remote_console/src/session/debug_session.dart';
class RemoteConsole {
  RemoteConsole({

    RemoteConsoleConfig config = const RemoteConsoleConfig(),
  }) : _engine = RemoteConsoleEngine(
          config: config,
          installationStorage: MemoryInstallationStorage(),
        );

  final RemoteConsoleEngine _engine;

  RemoteConsoleState get state => _engine.state;

  RemoteConsoleConfig get config => _engine.config;

  String? get installationId => _engine.installationId;

  List<ConsoleEvent> get recentEvents => _engine.recentEvents;

  int get bufferedEventCount => _engine.bufferedEventCount;

  bool get isDebugging => _engine.isDebugging;

  bool get isCapturing => _engine.isCapturing;

  DebugSession? get debugSession => _engine.debugSession;

  Future<void> initialize() {
    return _engine.initialize();
  }

  ConsoleEvent record({
    ConsoleEventLevel level = ConsoleEventLevel.info,
    required String source,
    required String message,
    Map<String, Object?>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return _engine.record(
      level: level,
      source: source,
      message: message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  FutureOr<void> runCaptured(
    FutureOr<void> Function() body,
  ) {
    return _engine.runCaptured(body);
  }

  void enableDeveloperMode() {
    _engine.enableDeveloperMode();
  }

  void disableDeveloperMode() {
    _engine.disableDeveloperMode();
  }

  void startDebugging() {
    _engine.startDebugging();
  }

  void stopDebugging() {
    _engine.stopDebugging();
  }

  void clearBuffer() {
    _engine.clearBuffer();
  }

  Future<void> dispose() {
    return _engine.dispose();
  }
}