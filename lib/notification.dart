import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

final notifications = FlutterLocalNotificationsPlugin();

initNotification(context) async {
  // 안드로이드용 아이콘파일 이름
  var androidSetting = const AndroidInitializationSettings('app_icon');

  // iOS에서 앱 로드시 유저에게 권한 요청
  var iosSetting = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings = InitializationSettings(
    android: androidSetting,
    iOS: iosSetting,
  );

  // 알림 초기화 및 권한 요청
  await notifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (payload) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Text(payload.toString())),
      );
    },
  );

  // 권한 요청
}

showNotification() async {
  var androidDetails = const AndroidNotificationDetails(
    'unique_notification_channel_id',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );

  var iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.show(
    1,
    '제목1',
    '내용1',
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: '부가정보',
  );
}

showNotification2() async {
  var androidDetails = const AndroidNotificationDetails(
    'unique_notification_channel_id',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );
  var iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  // tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  print(tz.getLocation('Asia/Seoul'));
  notifications.zonedSchedule(
      1,
      '제목2',
      '내용2',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, //신버전의 경우 윗줄 대신 추가
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
