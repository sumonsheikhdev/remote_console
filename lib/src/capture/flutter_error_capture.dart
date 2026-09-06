import 'package:flutter/foundation.dart';

typedef FlutterErrorHandler =
    void Function(FlutterErrorDetails details);

class FlutterErrorCapture {
  FlutterErrorCapture({
    required FlutterErrorHandler onError,
  }) : _onError = onError;

  final FlutterErrorHandler _onError;

  FlutterExceptionHandler? _previousHandler;

  bool _installed = false;

  void install() {
    if (_installed) {
      return;
    }

    _previousHandler = FlutterError.onError;

    FlutterError.onError = _handleError;

    _installed = true;
  }

  void uninstall() {
    if (!_installed) {
      return;
    }

    FlutterError.onError = _previousHandler;

    _previousHandler = null;
    _installed = false;
  }

  void _handleError(FlutterErrorDetails details) {
    _onError(details);

    // Preserve the application's existing Flutter error handler.
    _previousHandler?.call(details);
  }
}