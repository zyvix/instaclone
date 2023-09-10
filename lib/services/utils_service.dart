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


  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<bool> dialogCommon(
      BuildContext context, String title, String message, bool isSingle) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              !isSingle
                  ? MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              )
                  : const SizedBox.shrink(),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Confirm'),
              ),
            ],
          );
        });
  }

}