import 'remote_console_message_type.dart';

class RemoteConsoleMessage {
  const RemoteConsoleMessage({
    required this.type,
    this.payload,
  });

  final RemoteConsoleMessageType type;
  final Map<String, Object?>? payload;

  Map<String, Object?> toJson() {
    return {
      'type': type.name,
      if (payload != null) 'payload': payload,
    };
  }

  @override
  String toString() {
    return 'RemoteConsoleMessage('
        'type: ${type.name}'
        ')';
  }
}