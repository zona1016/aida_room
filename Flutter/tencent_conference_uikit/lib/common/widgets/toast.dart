import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_conference_uikit/common/index.dart';

makeToast({
  required String msg,
  Color backgroundColor = RoomColors.toastBlack,
  Color textColor = Colors.white,
}) {
  ToastUtils.showToast(
      title: msg);
}


class ToastUtils {
  ToastUtils._();

  static final _fToast = FToast();

  static init(BuildContext context) async {
    return _fToast.init(context);
  }

  static void showToast({required String title, Widget? icon, FToast? fToast}) {
    (fToast ?? _fToast).showToast(
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Center(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, height: 1, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

