import 'package:flutter/cupertino.dart';

class FloatWindowData {
  FloatWindowData._privateConstructor();
  static final FloatWindowData instance = FloatWindowData._privateConstructor();

  String? roomLink;
  Widget? chat;
  String? startTime;
  String? endTime;

  void clear() {
    roomLink = null;
    chat = null;
    startTime = null;
    endTime = null;
  }
}
