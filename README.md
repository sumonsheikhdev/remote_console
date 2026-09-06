# RemoteConsole

RemoteConsole is an open-source Flutter package for remote application console inspection and debugging.

It is designed to let a developer connect to a **specific Flutter app installation**, inspect its console output, receive diagnostic events, and eventually interact with a live debugging session through a CLI.

The project is being built with a strong focus on a clean underlying architecture, minimal dependencies, and a transport-independent core.

## Project Status

🚧 **Early development**

The Flutter package foundation is currently implemented and tested.

Current implementation includes:

* Installation identity
* Developer Mode
* Debug sessions
* Structured console events
* Local event ring buffer
* `print` capture
* `debugPrint` capture
* `FlutterError` capture
* Uncaught error capture
* Zone error capture
* Transport abstraction
* WebSocket transport
* RemoteConsole protocol foundation
* Public Flutter API

Current test status:

```text
75 tests passed
```

The remote server and CLI are planned for later stages.

## Architecture

RemoteConsole is structured in layers so the core debugging system does not depend directly on a particular transport.

```text
┌──────────────────────────────────────┐
│          Flutter Application         │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│          Console Capture             │
│                                      │
│  print • debugPrint • FlutterError   │
│  uncaught errors • zone errors       │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│        RemoteConsole Engine          │
│                                      │
│  Events • Identity • Sessions        │
│  Developer Mode • Buffer             │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│        RemoteConsole Protocol        │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│        Transport Abstraction         │
└──────────────────┬───────────────────┘
                   │
                   ▼
             WebSocket
                   │
                   ▼
          Remote Server / CLI
```

The important separation is:

```text
ConsoleEvent
     ↓
RemoteConsoleMessage
     ↓
ConsoleTransport
     ↓
WebSocket
```

This allows the underlying debugging system to remain independent from the delivery mechanism.

## Installation Identity

Every application installation receives a unique `installationId`.

The identity represents:

> one installation of one application

It is not intended to identify:

* the physical device
* the application user
* a hardware identifier

The identifier is persisted locally so the same installation can retain its identity across application launches.

## Developer Mode

Remote debugging is intentionally opt-in.

An application can enter Developer Mode when the developer wants to make the installation available for a debugging connection.

Conceptually:

```text
Application
    │
    ▼
Developer Mode
    │
    ▼
Ready for Developer Connection
    │
    ▼
Debug Session
```

This provides an explicit boundary between normal application operation and remote debugging.

## Console Events

RemoteConsole converts diagnostic information into structured events.

A console event contains information such as:

```json
{
  "id": "event-id",
  "timestamp": "2026-09-06T00:00:00Z",
  "level": "error",
  "source": "flutter",
  "message": "Example error",
  "stackTrace": "..."
}
```

Supported event sources currently include:

* `print`
* `debugPrint`
* `flutter`
* `uncaught`
* `zone`

Events can also contain metadata, errors, and stack traces.

## Local Event Buffer

Recent events are maintained in a local ring buffer.

```text
New Event
    │
    ▼
┌───────────────┐
│ Ring Buffer   │
│               │
│ event 1       │
│ event 2       │
│ event 3       │
│ ...           │
└───────────────┘
```

When the buffer reaches its configured capacity, the oldest events are removed.

This allows a debugging session to obtain recent diagnostic history without requiring every event to be continuously transmitted.

## Transport

RemoteConsole defines a transport abstraction:

```dart
abstract interface class ConsoleTransport {
  bool get isConnected;

  Future<void> connect();

  Future<void> send(ConsoleTransportEvent event);

  Stream<ConsoleTransportEvent> get events;

  Future<void> disconnect();
}
```

WebSocket is currently the first transport implementation.

The engine does not need to know that WebSocket is being used.

## Protocol

RemoteConsole uses its own protocol layer above the transport.

The protocol currently defines messages such as:

```text
hello
helloAck

debugRequest
debugAccepted
debugRejected
debugStopped

consoleEvent
consoleSnapshot

ping
pong
```

The protocol is intentionally separate from WebSocket.

WebSocket is only responsible for transporting messages.

## Intended Workflow

The long-term workflow is:

```text
Flutter App
     │
     │ Developer Mode
     ▼
RemoteConsole
     │
     │ WebSocket
     ▼
Remote Server
     │
     ▼
RemoteConsole CLI
```

A developer will eventually be able to use a command similar to:

```bash
remote-console debug <installationId>
```

to connect to a specific application installation.

## Design Principles

RemoteConsole is being developed around several principles.

### Minimal dependencies

The core should rely on Dart and Flutter primitives whenever practical.

Platform-specific functionality should remain isolated behind interfaces.

### Transport independence

The debugging engine should not be coupled to WebSocket.

```text
Engine
  │
  ▼
Transport Interface
  │
  ├── WebSocket
  └── Future transports
```

### Explicit debugging

Remote debugging should be explicitly enabled rather than silently exposing an application to remote connections.

### Installation-based identity

The primary identity is the application installation, not the user or physical device.

### Structured diagnostics

Console output should become structured data rather than remaining an unstructured stream of text.

### Layered architecture

Capture, events, buffering, sessions, protocol, and transport are separate concerns.

This makes the system easier to test, evolve, and extend.

## Roadmap

### Phase 1 — Foundation

* [x] Core package structure
* [x] Configuration
* [x] State management

### Phase 2 — Installation Identity

* [x] Installation ID generation
* [x] Persistent identity abstraction
* [x] Identity lifecycle

### Phase 3 — Console Event Engine

* [x] Structured console events
* [x] Event levels
* [x] Event IDs
* [x] Metadata
* [x] Error and stack-trace support

### Phase 4 — Event Buffer

* [x] Ring buffer
* [x] Configurable capacity
* [x] Snapshot
* [x] Clear

### Phase 5 — Event Pipeline

* [x] Event ingestion
* [x] Buffer integration

### Phase 6 — Console Capture

* [x] `print`
* [x] `debugPrint`
* [x] `FlutterError`
* [x] Uncaught errors
* [x] Zone errors

### Phase 7 — Public API

* [x] RemoteConsole facade
* [x] Installation integration
* [x] Developer Mode API

### Phase 8 — Debug Sessions

* [x] Debug session model
* [x] Session lifecycle
* [x] Installation association

### Phase 9 — Transport

* [x] Transport abstraction
* [x] Transport events

### Phase 10 — WebSocket

* [x] WebSocket connection
* [x] Sending messages
* [x] Receiving messages
* [x] Connection lifecycle
* [x] Tests

### Phase 11 — Remote Server

* [ ] Server
* [ ] Installation registration
* [ ] Developer connection handling
* [ ] Debug session coordination
* [ ] Event forwarding

### Phase 12 — CLI

* [ ] `remote-console` CLI
* [ ] Installation discovery
* [ ] Debug connection
* [ ] Live console
* [ ] Filtering
* [ ] Session controls

## Testing

The project currently has a comprehensive unit-test suite covering the implemented foundation.

Run:

```bash
flutter test
```

Current baseline:

```text
75 tests passed
```

## Contributing

Contributions, architectural discussions, bug reports, and improvements are welcome.

The project is still in early development, so APIs and protocol details may change before the first stable release.

## License

RemoteConsole is released under the MIT License.

See [LICENSE](LICENSE) for details.
