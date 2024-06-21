// ignore_for_file: public_member_api_docs

import 'dart:io';

class ShorebirdTracer {

  static final _traceFile = File('${const String.fromEnvironment('HOME')}/.shorebird_trace.log');

  static DateTime? _startTime;

  static void _writeToFile(String message) {
    _traceFile.writeAsStringSync('$message\n', mode: FileMode.append);
  }

  static void startTracing() {
    _startTime = DateTime.now();
  }

  static void endTracing(String label) {
    final startTime = _startTime;
    if (startTime == null) {
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    _startTime = null;
    _writeToFile('[$label] Duration: ${duration.inMilliseconds}');
  }
}
