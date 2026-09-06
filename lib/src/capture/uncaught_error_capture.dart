import 'dart:ui';

typedef UncaughtErrorHandler =
    bool Function(Object error, StackTrace stackTrace);

class UncaughtErrorCapture {
  UncaughtErrorCapture({
    required UncaughtErrorHandler onError,
  }) : _onError = onError;

  final UncaughtErrorHandler _onError;

  bool Function(Object error, StackTrace stackTrace)? _previousHandler;

  bool _installed = false;

  void install() {
    if (_installed) {
      return;
    }

    _previousHandler = PlatformDispatcher.instance.onError;

    PlatformDispatcher.instance.onError = _handleError;

    _installed = true;
  }

  void uninstall() {
    if (!_installed) {
      return;
    }

    PlatformDispatcher.instance.onError = _previousHandler;

    _previousHandler = null;
    _installed = false;
  }

  bool _handleError(Object error, StackTrace stackTrace) {
    final captured = _onError(error, stackTrace);

    final previous = _previousHandler;

    if (previous != null) {
      return previous(error, stackTrace);
    }

    return captured;
  }
}