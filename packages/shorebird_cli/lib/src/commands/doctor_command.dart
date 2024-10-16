import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:shorebird_cli/src/android_sdk.dart';
import 'package:shorebird_cli/src/android_studio.dart';
import 'package:shorebird_cli/src/doctor.dart';
import 'package:shorebird_cli/src/executables/executables.dart';
import 'package:shorebird_cli/src/logger.dart';
import 'package:shorebird_cli/src/network_checker.dart';
import 'package:shorebird_cli/src/shorebird_command.dart';
import 'package:shorebird_cli/src/shorebird_env.dart';
import 'package:shorebird_cli/src/shorebird_flutter.dart';
import 'package:shorebird_cli/src/version.dart';

/// {@template doctor_command}
/// `shorebird doctor`
/// A command that checks for potential issues with the current shorebird
/// environment.
/// {@endtemplate}
class DoctorCommand extends ShorebirdCommand {
  /// {@macro doctor_command}
  DoctorCommand() {
    argParser
      ..addFlag(
        'fix',
        abbr: 'f',
        help: 'Fix issues where possible.',
        negatable: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Enable verbose output.',
        negatable: false,
      );
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Show information about the installed tooling.';

  @override
  Future<int> run() async {
    final verbose = results['verbose'] == true;
    final shouldFix = results['fix'] == true;
    final flutterVersion = await _tryGetFlutterVersion();
    final output = StringBuffer();
    final shorebirdFlutterPrefix = StringBuffer('Flutter');

    if (flutterVersion != null) {
      shorebirdFlutterPrefix.write(' $flutterVersion');
    }
    output.writeln(
      '''
Shorebird $packageVersion • git@github.com:shorebirdtech/shorebird.git
$shorebirdFlutterPrefix • revision ${shorebirdEnv.flutterRevision}
Engine • revision ${shorebirdEnv.shorebirdEngineRevision}''',
    );

    if (verbose) {
      final notDetected = red.wrap('not detected');
      var javaVersion = notDetected;

      final javaExe = java.executable;
      if (javaExe != null) {
        final result = java.version;
        if (result != null) {
          javaVersion = result
              .split(Platform.lineTerminator)
              // Adds empty space to the version will be padded with the
              // JAVA_VERSION label.
              .join('${Platform.lineTerminator}                  ');
        }
      }

      String? gradlewVersion;
      if (gradlew.exists(Directory.current.path)) {
        gradlewVersion = await gradlew.version(Directory.current.path);
      }

      output.writeln('''

Logs: ${shorebirdEnv.logsDirectory.path}
Android Toolchain
  • Android Studio: ${androidStudio.path ?? notDetected}
  • Android SDK: ${androidSdk.path ?? notDetected}
  • ADB: ${androidSdk.adbPath ?? notDetected}
  • JAVA_HOME: ${java.home ?? notDetected}
  • JAVA_EXECUTABLE: ${javaExe ?? notDetected}
  • JAVA_VERSION: $javaVersion
  • Gradle: ${gradlewVersion ?? notDetected}''');
    }

    logger.info(output.toString());

    // ignore: cascade_invocations
    logger.info('URL reachability:');
    await networkChecker.checkReachability();
    logger.info('');

    if (verbose) {
      final progress = logger.progress('Performing GCP speed test');

      try {
        final speed = await networkChecker.performGCPSpeedTest();
        progress.complete('GCP Upload Speed: ${speed.toStringAsFixed(2)} MB/s');
      } on NetworkCheckerException catch (error) {
        progress.fail('GCP speed test failed: ${error.message}');
      } catch (error) {
        progress.fail('GCP speed test failed: $error');
      }
    }

    await doctor.runValidators(doctor.generalValidators, applyFixes: shouldFix);

    return ExitCode.success.code;
  }

  Future<String?> _tryGetFlutterVersion() async {
    try {
      return await shorebirdFlutter.getVersionString();
    } catch (error) {
      logger.detail('Unable to determine Flutter version.\n$error');
      return null;
    }
  }
}
