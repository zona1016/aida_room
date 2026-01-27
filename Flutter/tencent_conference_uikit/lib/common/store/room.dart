import 'dart:async';
import 'package:get/get.dart';
import 'package:tencent_conference_uikit/manager/rtc_engine_manager.dart';
import 'package:tencent_conference_uikit/common/index.dart';
import 'package:rtc_room_engine/rtc_room_engine.dart';

class RoomStore {
  static RoomStore get to => Get.find();
  final _screenShareUser = UserModel();
  final seatedUserList = <UserModel>[].obs;
  final userInfoList = <UserModel>[].obs;
  final inviteSeatList = <UserModel>[].obs;
  final Map<String, String> inviteSeatMap = {};
  final isSharing = false.obs;
  UserModel currentUser = UserModel();
  TUIRoomInfo roomInfo = TUIRoomInfo(roomId: '');
  VideoModel videoSetting = VideoModel();
  AudioModel audioSetting = AudioModel();
  final isFloatChatVisible = true.obs;
  int timeStampOnEnterRoom = 0;
  bool isEnteredRoom = false;
  final roomUserCount = 0.obs;

  static const _seatIndex = -1;
  static const _reqTimeout = 0;

  RxBool isMicItemTouchable = true.obs;
  RxBool isCameraItemTouchable = true.obs;

  // ========== 同步相关 ==========
  Timer? _syncTimer;
  static const int _syncIntervalSeconds = 300;
  bool _isSyncing = false;

  /// 启动定期同步
  void startPeriodicSync() {
    // 立即同步一次
    syncAllUsersFromServer();

    // 定期同步
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: _syncIntervalSeconds),
          (_) => syncAllUsersFromServer(),
    );
  }

  /// 停止定期同步
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// 从服务端全量同步用户列表
  Future<void> syncAllUsersFromServer() async {
    print('sdfsdfsdfdsfdsfsdfdsf');
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      List<TUIUserInfo> serverUsers = await _fetchAllUsersFromServer();
      if (serverUsers.isNotEmpty) {
        _mergeUserList(serverUsers);
        roomUserCount.value = serverUsers.length;
      }
    } catch (e) {
      print('syncAllUsersFromServer error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 分页拉取所有用户
  /// 分页拉取所有用户（递归方式）
  Future<List<TUIUserInfo>> _fetchAllUsersFromServer([int nextSequence = 0]) async {
    List<TUIUserInfo> allUsers = [];

    var result =
    await RoomEngineManager().getRoomEngine().getUserList(nextSequence);

    if (result.code != TUIError.success || result.data == null) {
      return allUsers;
    }

    allUsers.addAll(result.data!.userInfoList);

    // 如果还有下一页，递归获取并合并结果
    if (result.data!.nextSequence != 0) {
      List<TUIUserInfo> nextPageUsers =
      await _fetchAllUsersFromServer(result.data!.nextSequence);
      allUsers.addAll(nextPageUsers);
    }

    return allUsers;
  }

  /// 合并服务端列表到本地
  void _mergeUserList(List<TUIUserInfo> serverUsers) {
    Set<String> serverUserIds = serverUsers.map((u) => u.userId).toSet();
    Set<String> localUserIds =
    userInfoList.map((u) => u.userId.value).toSet();

    // 1. 删除本地有但服务端没有的用户
    List<String> usersToRemove =
    localUserIds.difference(serverUserIds).toList();
    for (var userId in usersToRemove) {
      removeUser(userId, userInfoList);
      removeUser(userId, seatedUserList);
    }

    // 2. 添加或更新用户
    for (var serverUser in serverUsers) {
      int index = getUserIndex(serverUser.userId, userInfoList);
      if (index == -1) {
        // 新用户，添加
        _addUserInternal(serverUser, userInfoList);
      } else {
        // 已存在，更新状态
        _updateExistingUser(serverUser, userInfoList[index]);
      }
    }

    // 3. 统一排序
    _sortUserList(userInfoList);
  }

  /// 更新已存在用户的状态
  void _updateExistingUser(TUIUserInfo serverUser, UserModel localUser) {
    localUser.userName.value = serverUser.userName;
    localUser.userAvatarURL.value = serverUser.avatarUrl;
    localUser.userRole.value = serverUser.userRole;
    localUser.hasVideoStream.value = serverUser.hasVideoStream!;
    localUser.hasAudioStream.value = serverUser.hasAudioStream!;
    localUser.hasScreenStream.value = serverUser.hasScreenStream!;

    if (serverUser.hasScreenStream == true) {
      isSharing.value = true;
      screenShareUser = UserModel.fromTUIUserInfo(serverUser);
    }
  }

  /// 内部添加用户（不排序）
  void _addUserInternal(TUIUserInfo userInfo, RxList<UserModel> destList) {
    if (userInfo.hasScreenStream == true) {
      isSharing.value = true;
      screenShareUser = UserModel.fromTUIUserInfo(userInfo);
    }
    destList.add(UserModel.fromTUIUserInfo(userInfo));
  }

  /// 统一排序规则
  void _sortUserList(RxList<UserModel> list) {
    list.sort((a, b) {
      // 1. 房主最前
      if (a.userRole.value == TUIRole.roomOwner) return -1;
      if (b.userRole.value == TUIRole.roomOwner) return 1;
      // 2. 管理员其次
      if (a.userRole.value == TUIRole.administrator &&
          b.userRole.value != TUIRole.administrator) return -1;
      if (b.userRole.value == TUIRole.administrator &&
          a.userRole.value != TUIRole.administrator) return 1;
      // 3. 按 userId 字母顺序（保证所有客户端一致）
      return a.userId.value.compareTo(b.userId.value);
    });
  }

  void clearStore() {
    stopPeriodicSync();

    screenShareUser = UserModel();
    userInfoList.clear();
    isSharing.value = false;
    currentUser = UserModel();
    roomInfo = TUIRoomInfo(roomId: '');
    videoSetting = VideoModel();
    audioSetting = AudioModel();
    isFloatChatVisible.value = true;
    seatedUserList.clear();
    inviteSeatList.clear();
    inviteSeatMap.clear();
    timeStampOnEnterRoom = 0;
    isEnteredRoom = false;
    isMicItemTouchable = true.obs;
    isCameraItemTouchable = true.obs;
    roomUserCount.value = 0;
  }

  UserModel get screenShareUser => _screenShareUser;

  set screenShareUser(UserModel userModel) {
    _screenShareUser.userId = userModel.userId;
    _screenShareUser.userName = userModel.userName;
    _screenShareUser.userAvatarURL = userModel.userAvatarURL;
    _screenShareUser.userRole = userModel.userRole;
    _screenShareUser.hasVideoStream = userModel.hasVideoStream;
    _screenShareUser.hasAudioStream = userModel.hasAudioStream;
    _screenShareUser.hasScreenStream = userModel.hasScreenStream;
  }

  Future<void> initialCurrentUser() async {
    TUILoginUserInfo loginUserInfo = TUIRoomEngine.getSelfInfo();
    var getCurrentUserResult =
    await RoomEngineManager().getUserInfo(loginUserInfo.userId);
    currentUser.userName.value = getCurrentUserResult.data!.userName;
    currentUser.userId.value = getCurrentUserResult.data!.userId;
    currentUser.userRole.value = getCurrentUserResult.data!.userRole;
    currentUser.userAvatarURL.value = getCurrentUserResult.data!.avatarUrl;
  }

  void addUserByList(
      List<TUIUserInfo> userInfoList, RxList<UserModel> destList) {
    for (var element in userInfoList) {
      addUser(element, destList);
    }
  }

  void addUser(TUIUserInfo userInfo, RxList<UserModel> destList) {
    int index = getUserIndex(userInfo.userId, destList);
    if (index != -1) {
      return;
    }
    if (userInfo.hasScreenStream == true) {
      isSharing.value = true;
      screenShareUser = UserModel.fromTUIUserInfo(userInfo);
    }
    destList.add(UserModel.fromTUIUserInfo(userInfo));
    _sortUserList(destList);
  }

  UserModel? getUserById(String userId) {
    int index = getUserIndex(userId, userInfoList);
    if (index == -1) {
      return null;
    }
    return userInfoList[index];
  }

  int getUserIndex(String userId, RxList<UserModel> destList) {
    return destList.indexWhere((element) => element.userId.value == userId);
  }

  void removeUser(String userId, RxList<UserModel> destList) {
    destList.removeWhere((element) => element.userId.value == userId);
  }

  void updateUserVideoState(String userId, bool hasVideo,
      TUIChangeReason reason, RxList<UserModel> destList,
      {bool? isScreenStream}) {
    var index = getUserIndex(userId, destList);
    if (index == -1) {
      return;
    }
    if (isScreenStream == true) {
      destList[index].hasScreenStream.value = hasVideo;
    } else {
      destList[index].hasVideoStream.value = hasVideo;
    }
  }

  void updateSelfVideoState(bool hasVideo, TUIChangeReason reason,
      {bool? isScreenStream}) {
    if (isScreenStream == true) {
      currentUser.hasScreenStream.value = hasVideo;
    } else {
      currentUser.hasVideoStream.value = hasVideo;
    }
    updateItemTouchableState();

    if (reason != TUIChangeReason.changedByAdmin) {
      return;
    }
    if (currentUser.hasVideoStream.value) {
      makeToast(msg: 'cameraTurnedOnByHostToast'.roomTr);
    } else if (!roomInfo.isCameraDisableForAllUser) {
      if (isRoomNeedTakeSeat() && !currentUser.isOnSeat.value) {
        return;
      }
      makeToast(msg: 'cameraTurnedOffByHostToast'.roomTr);
    }
  }

  void updateUserAudioState(String userId, bool hasAudio,
      TUIChangeReason reason, RxList<UserModel> destList) {
    var index = getUserIndex(userId, destList);
    if (index == -1) {
      return;
    }
    destList[index].hasAudioStream.value = hasAudio;
  }

  void updateSelfAudioState(bool hasAudio, TUIChangeReason reason) {
    currentUser.hasAudioStream.value = hasAudio;
    if (reason == TUIChangeReason.changedByAdmin) {
      if (hasAudio) {
        makeToast(msg: 'microphoneTurnedOnByHostToast'.roomTr);
      } else if (!roomInfo.isMicrophoneDisableForAllUser) {
        makeToast(msg: 'microphoneTurnedOffByHostToast'.roomTr);
      }
    }
    updateItemTouchableState();
  }

  void updateUserRole(String userId, TUIRole role, RxList<UserModel> destList) {
    var index = getUserIndex(userId, destList);
    if (index == -1) {
      return;
    }
    destList[index].userRole.value = role;
    _sortUserList(destList);
  }

  void updateSelfRole(TUIRole role) {
    if (isRoomNeedTakeSeat() &&
        !RoomStore.to.currentUser.isOnSeat.value &&
        role == TUIRole.roomOwner) {
      RoomEngineManager().takeSeat(_seatIndex, _reqTimeout, null);
    }
    if (role == TUIRole.roomOwner && !currentUser.ableSendingMessage.value) {
      RoomEngineManager()
          .disableSendingMessageByAdmin(currentUser.userId.value, false);
    }
  }

  void updateUserTalkingState(
      String userId, bool isTalking, RxList<UserModel> destList, int volume) {
    var index = getUserIndex(userId, destList);
    if (index == -1) {
      return;
    }
    if (!destList[index].hasAudioStream.value) {
      destList[index].isTalking.value = false;
      return;
    }
    destList[index].isTalking.value = isTalking;
    destList[index].volume.value = volume;

    if (userId == currentUser.userId.value) {
      currentUser.volume.value = volume;
    }
  }

  void updateUserSeatedState(String userId, bool isOnSeat,
      {TUIUserInfo? fallbackUserInfo}) {
    var index = getUserIndex(userId, userInfoList);

    if (index == -1) {
      if (fallbackUserInfo == null) return;
      addUser(fallbackUserInfo, userInfoList);
      index = getUserIndex(userId, userInfoList);
    }

    userInfoList[index].isOnSeat.value = isOnSeat;

    if (userId == currentUser.userId.value) {
      currentUser.isOnSeat.value = isOnSeat;
      if (!isOnSeat) {
        audioSetting.isMicDeviceOpened = false;
      }
      updateItemTouchableState();
    }
  }

  void updateUserMessageState(
      String userId, bool isDisable, RxList<UserModel> destList) {
    var index = getUserIndex(userId, destList);
    if (index == -1) {
      return;
    }
    destList[index].ableSendingMessage.value = !isDisable;

    if (userId == currentUser.userId.value) {
      currentUser.ableSendingMessage.value = !isDisable;
      if (isDisable) {
        makeToast(msg: 'messageTurnedOffByHostToast'.roomTr);
      } else {
        makeToast(msg: 'messageTurnedOnByHostToast'.roomTr);
      }
    }
  }

  void addInviteSeatUser(UserModel userModel, TUIRequest request) {
    if (inviteSeatMap.containsKey(request.userId)) {
      return;
    }
    inviteSeatList.add(userModel);
    inviteSeatMap[request.userId] = request.requestId;
  }

  void deleteInviteSeatUser(String userId) {
    inviteSeatList.removeWhere((element) => element.userId.value == userId);
    inviteSeatMap.removeWhere((key, value) => key == userId);
  }

  void deleteTakeSeatRequest(String requestId) {
    String userId = inviteSeatMap.entries
        .firstWhere(
          (entry) => entry.value == requestId,
      orElse: () => const MapEntry('', ''),
    )
        .key;
    if (userId.isNotEmpty) {
      deleteInviteSeatUser(userId);
    }
  }

  void initItemTouchableState() {
    if (roomInfo.isMicrophoneDisableForAllUser &&
        currentUser.userRole.value == TUIRole.generalUser) {
      isMicItemTouchable.value = false;
    }
    if (roomInfo.isCameraDisableForAllUser &&
        currentUser.userRole.value == TUIRole.generalUser) {
      isCameraItemTouchable.value = false;
    }
    if (isRoomNeedTakeSeat() && !currentUser.isOnSeat.value) {
      isMicItemTouchable.value = false;
      isCameraItemTouchable.value = false;
    }
  }

  void updateItemTouchableState() {
    if (currentUser.userRole.value == TUIRole.roomOwner) {
      isCameraItemTouchable.value = true;
      isMicItemTouchable.value = true;
      return;
    }
    if (currentUser.userRole.value == TUIRole.administrator) {
      if (isRoomNeedTakeSeat()) {
        if (currentUser.isOnSeat.value) {
          isCameraItemTouchable.value = true;
          isMicItemTouchable.value = true;
        } else {
          isCameraItemTouchable.value = false;
          isMicItemTouchable.value = false;
        }
        return;
      }
      isCameraItemTouchable.value = true;
      isMicItemTouchable.value = true;
      return;
    }
    if (isRoomNeedTakeSeat()) {
      if (currentUser.isOnSeat.value) {
        isCameraItemTouchable.value = true;
        isMicItemTouchable.value = true;
      } else {
        isCameraItemTouchable.value = false;
        isMicItemTouchable.value = false;
      }
    }
    if (roomInfo.isMicrophoneDisableForAllUser &&
        !currentUser.hasAudioStream.value) {
      isMicItemTouchable.value = false;
    } else {
      isMicItemTouchable.value = true;
    }
    if (roomInfo.isCameraDisableForAllUser &&
        !currentUser.hasVideoStream.value) {
      isCameraItemTouchable.value = false;
    } else {
      isCameraItemTouchable.value = true;
    }
  }

  bool isRoomNeedTakeSeat() {
    return roomInfo.isSeatEnabled == true &&
        roomInfo.seatMode == TUISeatMode.applyToTake;
  }
}