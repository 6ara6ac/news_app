import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

final ttsProvider = Provider((ref) {
  final tts = FlutterTts();
  return tts;
});
