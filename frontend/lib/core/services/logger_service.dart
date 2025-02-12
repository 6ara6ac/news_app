import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: false,
      printEmojis: false,
      printTime: true,
    ),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(),
    ]),
  );

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/debug_log.txt');
    FileOutput.file = file;
  }

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message) => _logger.e(message);
}

class FileOutput extends LogOutput {
  static File? file;

  @override
  void output(OutputEvent event) {
    file?.writeAsStringSync('${event.lines.join('\n')}\n',
        mode: FileMode.append);
  }
}
