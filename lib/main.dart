import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  var androidConfig = const FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText:
        "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.normal,
    notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable',
    ),
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  await FlutterBackground.enableBackgroundExecution();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserAccelerometerEvent? _userAccelerometerEvent;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  bool canExecute = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 145, 0),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'ScreamerBot',
          ),
        ),
        elevation: 4,
        backgroundColor: Colors.red,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),
      body: Center(
          child: Text(_userAccelerometerEvent?.z.toStringAsFixed(1) ?? '?')),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  var soundList = [
    "https://cdn.pixabay.com/audio/2022/01/18/audio_397285ac1c.mp3",
    "https://cdn.pixabay.com/audio/2022/10/16/audio_d7410dcb38.mp3",
    "https://cdn.pixabay.com/audio/2022/10/16/audio_97d5069a3e.mp3",
    "https://cdn.pixabay.com/audio/2022/03/15/audio_22bf573814.mp3",
    "https://cdn.pixabay.com/audio/2022/03/15/audio_7a545da2ba.mp3",
    "https://cdn.pixabay.com/audio/2022/10/09/audio_9f601ef813.mp3",
    "https://cdn.pixabay.com/audio/2022/03/15/audio_ca3561285f.mp3"
  ];
  void playScreamSound() async {
    final player = AudioPlayer();
    await player.play(UrlSource(soundList[Random().nextInt(6)]));
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEventStream(
        samplingPeriod: SensorInterval.fastestInterval,
      ).listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerEvent = event;
          });
          if (event.z <= -7) {
            if (canExecute) {
              canExecute = false;
              playScreamSound();
              Timer(
                const Duration(seconds: 1),
                () {
                  setState(() {
                    canExecute = true;
                  });
                },
              );
            }
          }
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor Not Found"),
                content: Text(
                  "It seems that your device doesn't support User Accelerometer Sensor",
                ),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
  }
}
