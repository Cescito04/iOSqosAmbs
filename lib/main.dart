import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qosambassadors/firebase_options.dart';
import 'package:qosambassadors/screens/authentification.dart';
import 'package:qosambassadors/screens/cellInfo.dart';
import 'package:qosambassadors/screens/challenge.dart';
import 'package:qosambassadors/screens/historique.dart';
import 'package:qosambassadors/screens/onboarding.dart';
import 'package:qosambassadors/screens/otp.dart';
import 'package:qosambassadors/screens/home.dart';
import 'package:qosambassadors/screens/profil.dart';
import 'package:qosambassadors/screens/ran_5g.dart';
import 'package:qosambassadors/screens/speedtest.dart';
import 'package:qosambassadors/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'controller/session_utilisateur.dart';
import 'controller/settings_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Add this import for SystemNavigator.pop

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _requestPermissions();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await initializeService();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );


  bool loggedIn = await UserSession.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn, savedThemeMode: savedThemeMode));
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.phone,
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.location,
  ].request();
}

Future<void> _checkGps(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Show a popup to enable location services
    _showGpsDialog(context);
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {

      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}

void _showGpsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("GPS désactivé"),
        content: Text("Veuillez activer le GPS pour utiliser cette application."),
        actions: <Widget>[
          TextButton(
            child: Text("Paramètres"),
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Annuler"),
            onPressed: () {
              SystemNavigator.pop(); // Exit the app
            },
          ),
        ],
      );
    },
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (service) => false,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  SettingsController settingsController = SettingsController();

  print("-------------------------------Background service started at: ${DateTime.now()}");

  DateTime now = DateTime.now();
  bool isTimeInRange = now.hour > 7 || (now.hour == 7 && now.minute >= 45) && now.hour < 18;
  if (isTimeInRange) {
    await settingsController.calculateSpeeds();
  }

  int intervalInMinutes = prefs.getInt('intervalInMinutes') ?? 60;
  Timer.periodic(Duration(minutes: intervalInMinutes), (timer) async {
    bool isSpeedTestEnabled = prefs.getBool('isSpeedTestEnabled') ?? false;
    if (!isSpeedTestEnabled) {
      service.stopSelf();
      timer.cancel();
      return;
    }

    DateTime now = DateTime.now();
    bool isTimeInRange = now.hour > 7 || (now.hour == 7 && now.minute >= 45) && now.hour < 18;
    if (!isTimeInRange) {
      service.stopSelf();
      timer.cancel();
      return;
    }

    print("Running scheduled task at: ${DateTime.now()}");
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}


class MyApp extends StatelessWidget {
  final bool loggedIn;
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({required this.loggedIn, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.orange,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orange,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/authentification': (context) => Authentification(),
          '/otp': (context) => Otp(),
          '/home': (context) => Home(),
          '/speedtest': (context) => SpeedTest(),
          '/settings': (context) => Settings(),
          '/historique': (context) => const Historique(),
          '/profile': (context) => const ProfilPage(),
          '/challenge': (context) => const Challenge(),
          '/cellinfo': (context) => Info(),
          '/cell5g': (context) => Cellule5G(),
        },
        title: 'Flutter Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: Builder(
          builder: (context) {
            _checkGps(context); // Ensure the GPS check is called here with the context
            return loggedIn ? Home() : OnBoarding();
          },
        ),
      ),
    );
  }
}
