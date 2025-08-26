import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rtc_room_engine/api/room/tui_room_engine.dart';
import 'package:tencent_conference_uikit/common/index.dart';
import 'package:rtc_room_engine/api/room/tui_room_define.dart';
import 'package:tencent_conference_uikit/common/room_base_color.dart';

import '../index.dart';

class RoomInfoSheet extends GetView<TopViewController> {
  const RoomInfoSheet({super.key, this.pwd, this.roomLink});

  final String? pwd;
  final String? roomLink;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Orientation orientation = MediaQuery.of(context).orientation;

        return BottomSheetWidget(
          height: orientation == Orientation.portrait
              ? 400.0.scale375()
              : Get.height,
          orientation: orientation,
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: orientation == Orientation.landscape,
                    child: SizedBox(height: 24.0.scale375()),
                  ),
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(
                      () => Text(
                        controller.roomName.value,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0.scale375Height()),
                  _buildListTile(
                      leading: 'roomId'.roomTr,
                      title: '',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.roomInfo.roomId,
                            style: const TextStyle(
                                fontSize: 14, color: RoomBaseColor.white),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          CopyTextButton(
                            infoText: controller.roomInfo.roomId,
                            successToast: 'copyRoomIdSuccess'.roomTr,
                          ),
                          const SizedBox(
                            width: 64,
                          ),
                          Text(
                            'invite_link'.roomTr,
                            style: const TextStyle(
                                fontSize: 14, color: RoomBaseColor.white),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: roomLink ?? ''));
                              makeToast(msg: 'invite_link_copied'.roomTr);
                            },
                            child: const Icon(
                              Icons.link_rounded,
                              color: RoomBaseColor.primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      )),
                  if (pwd != null && pwd!.isNotEmpty)
                    _buildListTile(
                      leading: 'meeting_password'.roomTr,
                      title: pwd!,
                    ),
                  _buildListTile(
                      leading: 'host'.roomTr,
                      title: '',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.roomInfo.ownerName ??
                                controller.roomInfo.ownerId,
                            style: const TextStyle(
                                fontSize: 14, color: RoomBaseColor.white),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Image.asset(
                            AssetsImages.roomOwner,
                            package: 'tencent_conference_uikit',
                          ),
                        ],
                      )),
                  _buildListTile(
                      leading: 'my_name'.roomTr,
                      title: '',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TUIRoomEngine.getSelfInfo().userName ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: RoomBaseColor.white),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Image.asset(
                            AssetsImages.roomOwner,
                            package: 'tencent_conference_uikit',
                          ),
                        ],
                      )),
                  Obx(() => _buildListTile(
                      leading: 'meeting_duration'.roomTr,
                      title: controller.timerText.value)),
                  const SizedBox(height: 16,),
                  Container(height: 10, color: RoomBaseColor.black,),
                  const SizedBox(height: 16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'current_free_version'.roomTr,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 12,
                          width: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.5),
                            color: RoomBaseColor.primaryColor
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Text(
                          'available_video_meetings'.roomTr,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'meeting_300_people_unlimited'.roomTr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 12,
                          width: 3,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.5),
                              color: RoomBaseColor.primaryColor
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Text(
                          'other_meeting_features'.roomTr,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'video_participant_limit'.roomTr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'co_host'.roomTr,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // _buildListTile(
                  //   leading: 'roomType'.roomTr,
                  //   title: controller.roomInfo.isSeatEnabled == false &&
                  //           controller.roomInfo.seatMode == TUISeatMode.freeToTake
                  //       ? 'freeToSpeakRoom'.roomTr
                  //       : 'onStageSpeakingRoom'.roomTr,
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildListTile(
      {required String leading, Widget? child, required String title}) {
    return SizedBox(
      height: 30.0.scale375Height(),
      child: ListTile(
        leading: Text(
          leading,
          style:
              const TextStyle(fontSize: 14, color: RoomBaseColor.weakTextColor),
        ),
        title: child ??
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: RoomBaseColor.white),
            ),
        minLeadingWidth: 80,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
