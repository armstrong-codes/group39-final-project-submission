import 'package:flutter_test/flutter_test.dart';
import 'package:group39_final_project_submission/firebase_options.dart';

void main() {
  test('Firebase options are available for the current platform', () {
    final options = DefaultFirebaseOptions.currentPlatform;

    expect(options.projectId, 'elimupath-733f9');
    expect(options.storageBucket, 'elimupath-733f9.firebasestorage.app');
  });
}
