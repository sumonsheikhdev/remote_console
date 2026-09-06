import 'package:flutter/foundation.dart';

typedef DebugPrintHandler = void Function(String line);

class DebugPrintCapture {
  DebugPrintCapture({
    required DebugPrintHandler onPrint,
  }) : _onPrint = onPrint;

  final DebugPrintHandler _onPrint;

  DebugPrintCallback? _previousPrint;

  bool _installed = false;

  void install() {
    if (_installed) {
      return;
    }

    _previousPrint = debugPrint;

    debugPrint = _handlePrint;

    _installed = true;
  }

  void uninstall() {
    if (!_installed) {
      return;
    }

    debugPrint = _previousPrint!;

    _previousPrint = null;
    _installed = false;
  }

  void _handlePrint(String? message, {int? wrapWidth}) {
    final line = message ?? '';

    _onPrint(line);

    final previous = _previousPrint;

    if (previous != null) {
      previous(
        line,
        wrapWidth: wrapWidth,
      );
    }
  }
}