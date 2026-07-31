import 'demo_backend.dart';
import 'elimu_backend.dart';

abstract final class AppServices {
  static ElimuBackend _backend = DemoElimuBackend();

  static ElimuBackend get backend => _backend;

  static void configure(ElimuBackend backend) {
    _backend = backend;
  }

  static void useDemoBackend() {
    _backend = DemoElimuBackend();
  }
}
