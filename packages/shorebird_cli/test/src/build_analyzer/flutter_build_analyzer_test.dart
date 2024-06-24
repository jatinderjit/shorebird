import 'dart:io';

import 'package:shorebird_cli/src/build_analyzer/flutter_build_analyzer.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterBuildAnalyzer', () {
    test('works', () {
      final file = File('test/fixtures/build_analyzer/build_out.txt');
      final analyzer = FlutterBuildAnalyzer();

      final lines = file.readAsLinesSync();

      for (final line in lines) {
        analyzer.processLine(line);
      }
      print(analyzer.times);
    });
  });
}
