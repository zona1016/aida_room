import 'package:flutter/services.dart';

class AudioRouteHelper {
  static const MethodChannel _channel =
  MethodChannel('audio_route');

  static Future<bool> isSpeakerOn() async {
    final bool result =
    await _channel.invokeMethod('isSpeakerOn');
    return result;
  }
}