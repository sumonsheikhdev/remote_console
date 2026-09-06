class DeveloperMode {
  bool _enabled = false;

  bool get isEnabled => _enabled;

  void enable() {
    _enabled = true;
  }

  void disable() {
    _enabled = false;
  }
}