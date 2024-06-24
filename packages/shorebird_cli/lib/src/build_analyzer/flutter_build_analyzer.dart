// ignore_for_file: public_member_api_docs

import 'dart:collection';
import 'dart:io';

class FlutterBuildAnalyzer {
  final _timeMap = <String, int>{};

  var _currentStep = '';
  final _stepTimes = <String>[];

  void processLine(String line) {
    final closingBracketIndex = line.indexOf(']');
    if (closingBracketIndex == -1) {
      return;
    }

    final timeContent = line.substring(1, closingBracketIndex);
    final lineContent = line.substring(closingBracketIndex + 1).trim();

    if (timeContent.trim().isNotEmpty) {
      _stepTimes.add(timeContent);
    }

    if (lineContent.startsWith('executing: ')) {
      _currentStep = lineContent.substring('executing: '.length);
    } else if (lineContent.startsWith('Exit code ') ||
        lineContent.startsWith('exiting with code')) {
      _consolidateTimes(_currentStep, _stepTimes);
      _stepTimes.clear();
    }
  }

  void _consolidateTimes(String currentStep, List<String> times) {
    _timeMap[currentStep] = times.isEmpty
        ? 0
        : times
            .map((time) => time.replaceAll(RegExp(r'\D'), ''))
            .map(int.parse)
            .reduce((value, element) => value + element);
  }

  void saveToFile() {
    File('.shorebird_build_times.log')
        // Intentionally not using writeAsStringSync to avoid blocking
        // the process
        .writeAsString(_timeMap.toString());
  }

  Map<String, int> get times => UnmodifiableMapView(_timeMap);
}
