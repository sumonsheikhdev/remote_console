class ConsoleTransportEvent {
  const ConsoleTransportEvent({
    required this.type,
    this.payload,
  });

  final String type;
  final Map<String, Object?>? payload;

  Map<String, Object?> toJson() {
    return {
      'type': type,
      if (payload != null) 'payload': payload,
    };
  }

  @override
  String toString() {
    return 'ConsoleTransportEvent('
        'type: $type'
        ')';
  }
}