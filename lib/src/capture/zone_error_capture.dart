import 'dart:async';

typedef ZoneErrorHandler =
    void Function(Object error, StackTrace stackTrace);

class ZoneErrorCapture {
  ZoneErrorCapture({
    required ZoneErrorHandler onError,
  }) : _onError = onError;

  final ZoneErrorHandler _onError;

  Future<void> run(
    FutureOr<void> Function() body,
  ) {
    final completer = Completer<void>();

    runZonedGuarded(
      () {
        Future.sync(body).then(
          (_) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        );
      },
      (error, stackTrace) {
        _onError(error, stackTrace);

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    return completer.future;
  }
}