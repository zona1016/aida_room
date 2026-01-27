import 'package:flutter/services.dart';

class AudioRouteHelper {
  static const MethodChannel _channel = MethodChannel('audio_route');

  /// 检查扬声器是否打开
  static Future<bool> isSpeakerOn() async {
    final bool result = await _channel.invokeMethod('isSpeakerOn');
    return result;
  }

  /// 播放音效（单次）
  static Future<void> playSound() async {
    await _channel.invokeMethod('playSound');
  }

  /// 进入会议 / 开启 RTC 音频通话模式
  static Future<void> enableRtcAudio() async {
    await _channel.invokeMethod('enableRtcAudio');
  }

  /// 离开会议 / 恢复普通音频模式
  static Future<void> disableRtcAudio() async {
    await _channel.invokeMethod('disableRtcAudio');
  }
}
