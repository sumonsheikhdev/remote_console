enum RemoteConsoleMessageType {
  hello,
  helloAck,

  debugRequest,
  debugAccepted,
  debugRejected,
  debugStopped,

  consoleEvent,
  consoleSnapshot,

  ping,
  pong,
}