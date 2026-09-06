
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'debug_print_capture.dart';
import 'flutter_error_capture.dart';
import 'print_capture.dart';
import 'uncaught_error_capture.dart';
import 'zone_error_capture.dart';

typedef ConsoleCaptureEventHandler = void Function({
  required String source,
  required String message,
  Object? error,
  StackTrace? stackTrace,
});

class ConsoleCapture {
  ConsoleCapture({
    required ConsoleCaptureEventHandler onEvent,
  }) : _onEvent = onEvent;

  final ConsoleCaptureEventHandler _onEvent;

  late final FlutterErrorCapture _flutterErrorCapture =
      FlutterErrorCapture(
    onError: _handleFlutterError,
  );

  late final UncaughtErrorCapture _uncaughtErrorCapture =
      UncaughtErrorCapture(
    onError: _handleUncaughtError,
  );

  late final ZoneErrorCapture _zoneErrorCapture =
      ZoneErrorCapture(
    onError: _handleZoneError,
  );

  late final PrintCapture _printCapture =
      PrintCapture(
    onPrint: _handlePrint,
  );

  late final DebugPrintCapture _debugPrintCapture =
      DebugPrintCapture(
    onPrint: _handleDebugPrint,
  );

  bool _installed = false;

  bool get isInstalled => _installed;

  void install() {
    if (_installed) {
      return;
    }

    _flutterErrorCapture.install();
    _uncaughtErrorCapture.install();
    _debugPrintCapture.install();

    _installed = true;
  }

  void uninstall() {
    if (!_installed) {
      return;
    }

    _debugPrintCapture.uninstall();
    _uncaughtErrorCapture.uninstall();
    _flutterErrorCapture.uninstall();

    _installed = false;
  }

  FutureOr<void> runZoned(
    FutureOr<void> Function() body,
  ) {
    return _zoneErrorCapture.run(
      () => _printCapture.run(body),
    );
  }

  void _handleFlutterError(
    FlutterErrorDetails details,
  ) {
    _onEvent(
      source: 'flutter',
      message: details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  bool _handleUncaughtError(
    Object error,
    StackTrace stackTrace,
  ) {
    _onEvent(
      source: 'uncaught',
      message: error.toString(),
      error: error,
      stackTrace: stackTrace,
    );

    return false;
  }

  void _handleZoneError(
    Object error,
    StackTrace stackTrace,
  ) {
    _onEvent(
      source: 'zone',
      message: error.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _handlePrint(String line) {
    _onEvent(
      source: 'print',
      message: line,
    );
  }

  void _handleDebugPrint(String line) {
    _onEvent(
      source: 'debugPrint',
      message: line,
    );
  }
}
