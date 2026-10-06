class ConsoleTransportEvent {
  const ConsoleTransportEvent({
    required this.type,
    this.payload,
    this.fields,
  });

  final String type;
  final Map<String, Object?>? payload;

  /// Additional protocol-level fields that should be serialized
  /// alongside `type`.
  final Map<String, Object?>? fields;

  Map<String, Object?> toJson() {
    return {
      'type': type,
      if (payload != null) 'payload': payload,
      ...?fields,
    };
  }

  @override
  String toString() {
    return 'ConsoleTransportEvent('
        'type: $type'
        ')';
  }
}