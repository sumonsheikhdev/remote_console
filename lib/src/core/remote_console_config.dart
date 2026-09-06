class RemoteConsoleConfig {
  const RemoteConsoleConfig({
    this.enabled = true,
    this.maxBufferedEvents = 500,
  });

  final bool enabled;

  final int maxBufferedEvents;
}