import 'dart:convert';
import 'dart:io';

import 'package:flutter_build_analyzer/flutter_build_analyzer.dart'
    as flutter_build_analyzer;

void main(List<String> arguments) async {

  if (arguments.isEmpty) {
    printUsage();
    return;
  }

  final index = arguments.first == 'dart' ? 1 : 0;

  if (arguments.length < index + 2 || arguments[index + 1] != 'flutter') {
    printUsage();
    return;
  }

  if (!arguments.contains('-v')) {
    arguments.add('-v');
    print('Adding -v to the arguments');
  }

  final fileName = arguments[index];


  final analyzer = flutter_build_analyzer.FlutterBuildAnalyzer(
    fileNamePath: fileName,
  );

  final executable = arguments[index + 1];
  final args = arguments.sublist(index + 2);

  final process = await Process.start(executable, args);

  process.stdout.transform(utf8.decoder).listen(analyzer.processLine);
  process.stderr.listen(stderr.add);

  final exitCode = await process.exitCode;

  await analyzer.saveToFile();
  print('Wrote to $fileName');
  print('Exit code: $exitCode');
}

void printUsage() {
  print('Usage: flutter_build_analyzer file_name  flutter ...');
}
