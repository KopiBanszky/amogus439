import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amogusvez2/admin/AddPoint.dart';
import 'package:amogusvez2/admin/MainAdmin.dart';
import 'package:amogusvez2/pages/GameEnd.dart';
import 'package:amogusvez2/pages/GameMain.dart';
import 'package:amogusvez2/pages/Navigation_minigame.dart';
import 'package:amogusvez2/pages/VotedOut.dart';
import 'package:amogusvez2/pages/Voting.dart';
import 'package:amogusvez2/pages/Waiting.dart';
import 'package:amogusvez2/pages/lobby.dart';
import 'package:amogusvez2/pages/qr_reader.dart';
import 'package:amogusvez2/pages/roleReveal.dart';
import 'package:amogusvez2/pages/settings.dart';
import 'package:amogusvez2/pages/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amogusvez2/pages/home.dart';
import 'package:amogusvez2/utility/globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'pages/Map.dart';

Future<void> main() async {
  if(!kIsWeb) WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb) await initializeService();
  runApp(MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        '/lobby': (context) => const LobbyPage(),
        '/settings': (context) => const SettingsPage(),
        '/roleReveal': (context) => const RoleRevealPage(),
        '/gameMain': (context) => const GameMainPage(),
        '/qrReader': (context) => const SrReaderPage(),
        '/waitingForVote': (context) => const WaitingPage(),
        '/voting': (context) => const VotingPage(),
        '/votingResult': (context) => const VotedOutPage(),
        '/admin': (context) => const AdminMainPage(),
        '/addPoint': (context) => const AddPointPage(),
        '/map': (context) => const MapPage(),
        '/test': (context) => const Test(),
        '/navigation': (context) => const NavigationMinigame(),
        '/gameEnd': (context) => const GameEndPage(),
      },
      theme: ThemeData(

          // fontFamily: 'DeliciousHandrawn'
          )));
}

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'Among us 439', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId:
            notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'Among Us 439',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
          // this will be executed when app is in foreground or background in separated isolate

          ));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'Among Us 439',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'Among Us 439',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}
