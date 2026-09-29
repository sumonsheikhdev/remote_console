class RemoteConsoleConfig {
  const RemoteConsoleConfig({
    this.enabled = true,
    this.maxBufferedEvents = 500,
    this.serverUrl,
  });

  final bool enabled;
  final int maxBufferedEvents;

  /// WebSocket server URL.
  ///
  /// Example:
  /// ws://127.0.0.1:8080/ws
  final String? serverUrl;
}