import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tencent_conference_uikit/common/index.dart';
import 'package:tencent_conference_uikit/pages/conference_main/widgets/widgets.dart';

import 'widgets/widgets.dart';

class TopViewWidget extends GetView<TopViewController> {
  const TopViewWidget(this.orientation, {Key? key, this.pwd, this.roomLink, this.endTime, this.startTime}) : super(key: key);

  final Orientation orientation;
  final String? pwd;
  final String? roomLink;
  /// 结束时间
  final String? endTime;
  /// 开始时间
  final String? startTime;

  Widget _buildView() {
    return Container(
      width: Get.width,
      height: orientation == Orientation.portrait
          ? 105.0.scale375()
          : 73.0.scale375(),
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: orientation == Orientation.portrait
                ? 44.0.scale375Height()
                : 20.0.scale375(),
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16.0.scale375()),
                TopButtonItemWidget(
                    image: Image.asset(
                      AssetsImages.roomEarpiece,
                      package: 'tencent_conference_uikit',
                      width: 20.0.scale375(),
                      height: 20.0.scale375(),
                    ),
                    selectedImage: Image.asset(
                      AssetsImages.roomSpeakerphone,
                      package: 'tencent_conference_uikit',
                      width: 20.0.scale375(),
                      height: 20.0.scale375(),
                    ),
                    onPressed: () => {controller.switchSpeakerAction()},
                    isSelected: RoomStore.to.audioSetting.isSoundOnSpeaker),
                SizedBox(width: 24.0.scale375()),
                RoomStore.to.currentUser.hasVideoStream.value
                    ? TopButtonItemWidget(
                        image: Image.asset(
                          AssetsImages.roomSwitchCamera,
                          package: 'tencent_conference_uikit',
                          width: 20.0.scale375(),
                          height: 20.0.scale375(),
                        ),
                        onPressed: () => {controller.switchCameraAction()},
                        isSelected: false.obs,
                      )
                    : SizedBox(width: 20.0.scale375()),
                SizedBox(width: 16.0.scale375()),
                const Spacer(),
                MeetingTitleWidget(orientation, pwd: pwd, roomLink: roomLink,),
                const Spacer(),
                TopButtonItemWidget(
                  image: Image.asset(
                    AssetsImages.roomExit,
                    package: 'tencent_conference_uikit',
                    width: 20.0.scale375(),
                    height: 20.0.scale375(),
                  ),
                  onPressed: () => {
                    showConferenceBottomSheet(const ExitWidget(),
                        alwaysFromBottom: true)
                  },
                  isSelected: false.obs,
                  text: 'exit'.roomTr,
                ),
                SizedBox(width: 16.0.scale375()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopViewController>(
      init: TopViewController(endTime: endTime, startTime: startTime),
      id: "topview",
      builder: (_) {
        return Container(
          color: Colors.white.withValues(alpha: 0.1),
          child: _buildView(),
        );
      },
      autoRemove: false,
    );
  }
}
