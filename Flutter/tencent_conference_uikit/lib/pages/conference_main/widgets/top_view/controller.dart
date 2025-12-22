import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rtc_room_engine/rtc_room_engine.dart';
import 'package:tencent_conference_uikit/common/extension/index.dart';
import 'package:tencent_conference_uikit/common/store/index.dart';
import 'package:tencent_conference_uikit/common/style/theme.dart';
import 'package:tencent_conference_uikit/common/widgets/dialog.dart';
import 'package:tencent_conference_uikit/manager/conference_list_manager.dart';
import 'package:tencent_conference_uikit/manager/rtc_engine_manager.dart';
import 'package:tencent_conference_uikit/pages/conference_main/index.dart';

class TopViewController extends GetxController with WidgetsBindingObserver {
  /// 结束时间
  final String? endTime;

  /// 结束时间
  final String? startTime;

  TopViewController({this.endTime, this.startTime});

  final RoomEngineManager _engineManager = RoomEngineManager();
  late TUIRoomInfo roomInfo;
  RxString roomName = ''.obs;
  late TUIConferenceListManagerObserver observer;
  final conferenceMainController = Get.find<ConferenceMainController>();

  Timer? topMenuTimer;
  bool _timerRunning = false;
  RxString timerText = '00:00'.obs;
  bool showAlert = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    roomInfo = RoomStore.to.roomInfo;
    roomName.value = roomInfo.name ?? roomInfo.roomId;
    _initObserver();
    updateTimerLabelText();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      recalculateTimerFromStartTime();
    }
  }

  void recalculateTimerFromStartTime() {
    final int start = int.tryParse(startTime ?? '') ?? 0;
    if (start <= 0) return;

    // 防止重复启动
    if (_timerRunning) return;
    _timerRunning = true;

    _updateFromStart(start);

    topMenuTimer?.cancel();
    topMenuTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateFromStart(start);
    });
  }

  void _updateFromStart(int start) {
    final int now = DateTime.now().millisecondsSinceEpoch;

    // ❗不要 abs
    final int totalSeconds = ((now - start) ~/ 1000).clamp(0, 1 << 31);

    updateTimer(totalSeconds: totalSeconds);
    needEdit();
  }

  void onAppPaused() {
    _timerRunning = false;
    topMenuTimer?.cancel();
    topMenuTimer = null;
  }

  void _initObserver() {
    observer = TUIConferenceListManagerObserver(
      onConferenceInfoChanged: (conferenceInfo, modifyFlagList) {
        if (conferenceInfo.basicRoomInfo.roomId == roomInfo.roomId &&
            modifyFlagList.contains(TUIConferenceModifyFlag.roomName)) {
          roomName.value = conferenceInfo.basicRoomInfo.name ??
              conferenceInfo.basicRoomInfo.roomId;
          roomInfo.name = roomName.value;
        }
      },
    );
    ConferenceListManager().addObserver(observer);
  }

  void updateTimerLabelText() {
    int currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    int totalSeconds =
        ((currentTimeStamp - (double.parse(startTime ?? '0').toInt())) / 1000)
            .abs()
            .floor();

    updateTimer(totalSeconds: totalSeconds);

    topMenuTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      totalSeconds += 1;
      updateTimer(totalSeconds: totalSeconds);
      needEdit();
    });
  }

  void needEdit() {
    if (double.parse(endTime ?? '0').toInt() <=
        DateTime.now().millisecondsSinceEpoch) {
      topMenuTimer?.cancel();
      if (showAlert) return;
      showAlert = true;
      conferenceMainController.conferenceObserver?.onConferenceFinished
          ?.call(RoomStore.to.roomInfo.roomId);
      if (roomInfo.ownerId == TUIRoomEngine.getSelfInfo().userId) {
        _engineManager.destroyRoom();
      } else {
        _engineManager.exitRoom();
      }
      showConferenceDialog(
        title: 'meeting_time_over'.roomTr,
        confirmText: 'ok'.roomTr,
        confirmTextStyle: RoomTheme.defaultTheme.textTheme.labelMedium,
        onConfirm: () {
          Get.until((route) {
            var args = route.settings.arguments;
            if (args is Map) {
              return route is! PopupRoute &&
                  args['from'] != 'ConferenceMainPage';
            }
            return route is! PopupRoute;
          });
          Get.back();
        },
        barrierDismissible: false,
      );
    }
  }

  void updateTimer({required int totalSeconds}) {
    int second = totalSeconds % 60;
    int minute = (totalSeconds ~/ 60) % 60;
    int hour = totalSeconds ~/ 3600;

    if (hour > 0) {
      timerText.value =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
    } else {
      timerText.value =
          "${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
    }
  }

  void switchSpeakerAction() {
    RoomStore.to.audioSetting.isSoundOnSpeaker.value =
        !RoomStore.to.audioSetting.isSoundOnSpeaker.value;
    _engineManager
        .setAudioRoute(RoomStore.to.audioSetting.isSoundOnSpeaker.value);
  }

  void switchCameraAction() {
    _engineManager.switchCamera();
  }

  @override
  void onClose() {
    super.onClose();
    topMenuTimer?.cancel();
    ConferenceListManager().removeObserver(observer);
  }
}
