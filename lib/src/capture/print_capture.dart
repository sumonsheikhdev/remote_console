import 'dart:async';

typedef PrintHandler = void Function(String line);

class PrintCapture {
  PrintCapture({
    required PrintHandler onPrint,
  }) : _onPrint = onPrint;

  final PrintHandler _onPrint;

  FutureOr<void> run(
    FutureOr<void> Function() body,
  ) {
    final zoneSpecification = ZoneSpecification(
      print: (
        self,
        parent,
        zone,
        line,
      ) {
        _onPrint(line);

        parent.print(zone, line);
      },
    );

    return Zone.current.fork(
      specification: zoneSpecification,
    ).run(body);
  }
}