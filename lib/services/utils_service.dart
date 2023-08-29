import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils{

  static void fireToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16
    );
  }

  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = {};
    String fcmToken = "";
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo? androidDeviceInfo;
    IosDeviceInfo? iosDeviceInfo;
    String? idAndroid;
    String? idIOS;

    if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      idIOS = iosDeviceInfo.identifierForVendor;
    } else {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      idAndroid = androidDeviceInfo.id;
    }

    if (Platform.isIOS) {
      if (idIOS != null) {
        params.addAll({
          'device_id': idIOS,
          'device_type': "I",
          'device_token': fcmToken,
        });
      }
    } else {
      if (idAndroid != null) {
        params.addAll({
          'device_id': idAndroid,
          'device_type': "A",
          'device_token': fcmToken,
        });
      }
    }

    return params;
  }

}