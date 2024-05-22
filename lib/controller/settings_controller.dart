import 'dart:convert';

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_type_reachability/network_type_reachability.dart';

import 'package:qosambassadors/screens/speedtest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../services/services.dart';
import '../services/settings_services.dart';

class SettingsController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int testsEffectues = 0;
  String _newDLmin = '';
  String _newULmin = '';
  DateTime currentDate = DateTime.now();
  SpeedTest speedTest = SpeedTest();
  String combinedSpeedPhrase = '';
  String connTypeValue = '_';
  String ambassadorId = '';
  String dlSpeedValue = '_';
  String ulSpeedValue = '_';
  String pingValue = '_';

  String phoneNumber = '';
  bool isActivated = false;
  bool isFormVisible = false;

  ReceivePort downloadReceivePort = ReceivePort();
  ReceivePort uploadReceivePort = ReceivePort();

  double lastULMinValue = 0.0;
  double lastDLMinValue = 0.0;
  DateTime? _intervalleFixe;
  int calculatedIntervalSeconds = 0;

  String get newDLmin => _newDLmin;
  DateTime? _nextTestTime;


  DateTime? get nextTestTime => _nextTestTime;

  SettingService settingService = SettingService();

  set newDLmin(String value) {
    _newDLmin = value;
  }

  String get newULmin => _newULmin;

  set newULmin(String value) {
    _newULmin = value;
  }

  final FocusNode ulFocusNode = FocusNode();
  final FocusNode dlFocusNode = FocusNode();
  final FocusNode testsFocusNode = FocusNode();

  late TextEditingController ulminController;
  late TextEditingController dlminController;

  SettingsController() {
    ulminController = TextEditingController(text: newULmin);
    dlminController = TextEditingController(text: newDLmin);
    loadButtonState();
    loadNombreDeTestsSelectionne();
    getUserParameters();
  }

  void dispose() {
    ulFocusNode.dispose();
    dlFocusNode.dispose();
    testsFocusNode.dispose();
  }

  List<int> optionsNombreDeTests = [5, 10, 15, 20, 25, 30];
  int nombreDeTestsSelectionne = 5;
  Future<void> saveNombreDeTestsSelectionne(int nombreDeTests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nombreDeTestsSelectionne', nombreDeTests);
    nombreDeTestsSelectionne = nombreDeTests;
    print(
        "--------------------------------Saved nombreDeTests: $nombreDeTests");
  }

  Future<bool> loadButtonState() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isButtonActivated') ?? false;
  }

  void getUserParameters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ambassadorId = prefs.getString('ambassadorId') ?? "";
    if (kDebugMode) {
      print("idparams : $ambassadorId");
    }

    var url = 'https://qosambassadors.herokuapp.com/le-bon-coins';
    var queryParams = {
      'filter': '{"where": {"ambassadorId": "$ambassadorId"}}'
    };

    try {
      var response = await http.get(Uri.parse(url), headers: queryParams);

      if (response.statusCode == 200) {
        var res = response.body;

        if (res.isNotEmpty) {
          var decodedResponse = json.decode(res);
          var firstItem = decodedResponse[0];

          if (firstItem.containsKey('id')) {
            newDLmin = firstItem['dl'];
            newULmin = firstItem['ul'];

            ulminController.text = newULmin;
            dlminController.text = newDLmin;
          }
          if (kDebugMode) {
            print("UL : $newULmin");
            print("DL : $newDLmin");
            print("Test : $nombreDeTestsSelectionne");
          }
        } else {
          if (kDebugMode) {
            print("Response body is empty");
          }
        }
      } else {
        if (kDebugMode) {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during API call: $error');
      }
    }
  }

  Future<void> loadNombreDeTestsSelectionne() async {
    final prefs = await SharedPreferences.getInstance();
    nombreDeTestsSelectionne = prefs.getInt('nombreDeTestsSelectionne') ?? 10;
  }

  Future<void> saveFormFieldValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> getNetworkType() async {
    NetworkStatus status =
    await NetworkTypeReachability().currentNetworkStatus();
    String networkType = 'unknown';
    switch (status) {
      case NetworkStatus.unreachable:
        networkType = 'no connection';
        break;
      case NetworkStatus.wifi:
        networkType = 'wifi';
        break;
      case NetworkStatus.mobile2G:
        networkType = '2G';
        break;
      case NetworkStatus.moblie3G:
        networkType = '3G';
        break;
      case NetworkStatus.moblie4G:
        networkType = '4G';
        break;
      case NetworkStatus.moblie5G:
        networkType = '5G';
        break;
      case NetworkStatus.otherMoblie:
        networkType = 'other mobile';
        break;
    }
    connTypeValue = networkType;
  }

  Future<double> calculateDownloadSpeed() async {
    final String downloadTestURL = Services().downloadUrl();
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(downloadTestURL));
      stopwatch.stop();
      if (response.statusCode == 200) {
        final fileSizeBytes = response.contentLength;
        if (fileSizeBytes != null) {
          final downloadTimeSeconds = stopwatch.elapsedMilliseconds / 1000.0;
          final downloadSpeedMbps = (fileSizeBytes * 8) / (downloadTimeSeconds * 1024 * 1024);
          return downloadSpeedMbps ;
        } else {
          throw Exception('Failed to get file size.');
        }
      } else {
        throw Exception('Download test failed. Status code: ${response.statusCode}.');
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on HttpException {
      throw Exception('Failed to load data.');
    } on FormatException {
      throw Exception('Bad response format.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<double> calculateUploadSpeed() async {
    final String uploadTestURL = Services().uploadUrl();
    final List<int> bytes = List.filled(1024 * 1024, 0);
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(uploadTestURL),
        body: base64Encode(bytes),
        headers: {'Content-Type': 'application/octet-stream'},
      );
      stopwatch.stop();
      if (response.statusCode == 200) {
        final encodedSize = base64Encode(bytes).length;
        final uploadTimeSeconds = stopwatch.elapsedMilliseconds / 1000;
        final uploadSpeedMbps = (encodedSize * 8) / (uploadTimeSeconds * 1024 * 1024);
        return uploadSpeedMbps ;
      } else {
        throw Exception('Failed to upload data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during upload speed test: $e');
    }
  }

  Future<int> measurePing() async {
    const String targetUrl = 'http://41.82.224.3/download';
    final int start = DateTime.now().millisecondsSinceEpoch;
    int pingTime = -1;

    try {
      final response = await http.head(Uri.parse(targetUrl));

      if (response.statusCode == 200) {
        final int end = DateTime.now().millisecondsSinceEpoch;
        pingTime = end - start;
      } else {
        if (kDebugMode) {
          print('Ping request error. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error measuring ping: $e');
      }
    }

    return pingTime;
  }

  Future<void> saveDataHistory(double downloadSpeed, double uploadSpeed,
      int ping, double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ambassadorId = prefs.getString('ambassadorId') ?? "";
    dlSpeedValue = downloadSpeed.toStringAsFixed(2);
    ulSpeedValue = uploadSpeed.toStringAsFixed(2);
    pingValue = ping.toString();
    String networkType = await NetworkService.getNetworkType();

    try {
      final response = await settingService.post(
        (Services().historyUrl()),
        {
          "techno": networkType,
          "ping": double.parse(pingValue),
          "download": double.parse(dlSpeedValue),
          "upload": double.parse(ulSpeedValue),
          "latitude": latitude,
          "longitude": longitude,
          "ambassadorId": ambassadorId,
          "date": _getCurrentFormattedDate(),
          "type": "auto     ",
          "ulmin": double.parse(_newULmin),
          "dlmin": double.parse(_newDLmin),
        },
      );
      if (kDebugMode) {
        print("response : $response");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de l'analyse des valeurs : $e");
      }
    }
  }

  String _getCurrentFormattedDate() {
    return currentDate.toIso8601String();
  }

  Future<String> fetchPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ambassadorId = prefs.getString('ambassadorId') ?? "";
    if (ambassadorId.isEmpty) {
      if (kDebugMode) {
        print('Ambassador ID is not available.');
      }
      return '';
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${SettingService.ambassadorsEndpoint()}?filter={"where": {"id": "$ambassadorId"}}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          String phoneNumber = data.first['numero'];
          return phoneNumber;
        } else {
          if (kDebugMode) {
            print('User profile not found.');
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch user profile. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }

    return '';
  }

  Future<void> sendSpeedToServerWithMessage() async {
    String phoneNumber = await fetchPhoneNumber();
    if (phoneNumber.isEmpty) {
      print('Le numéro de téléphone n\'est pas disponible.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String networkType = await NetworkService.getNetworkType();

      String message =
          'Resultat test de Débit ($networkType) DL=$dlSpeedValue Mbps, UL=$ulSpeedValue Mbps';

      final messageEndpoint =
          '${SettingService.sendSMSEndpoint(phoneNumber, message)}';

      final response = await http.get(Uri.parse(messageEndpoint));
      if (response.statusCode == 200) {
        print('Message avec la localisation et la vitesse envoyé avec succès.');
      } else {
        print(
            'Échec de l\'envoi du message. Code de statut: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
    }
  }

  Future<void> deleteOldValue(String ambassadorId) async {
    var deleteUrl = Uri.parse(
        '${SettingService.deleteLeBonCoinEndpoint(ambassadorId)}');
    try {
      var deleteResponse = await http.delete(deleteUrl);
      if (deleteResponse.statusCode == 200) {
        if (kDebugMode) {
          print('Ancienne valeur supprimée avec succès.');
        }
      } else {
        if (kDebugMode) {
          print(
              'Échec de la suppression de l\'ancienne valeur. Code: ${deleteResponse.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de l\'ancienne valeur: $e');
      }
    }
  }

  Future<void> handleSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      if (kDebugMode) {
        print('ul is $_newULmin');
        print('dl is $_newDLmin');
        print('tests is $nombreDeTestsSelectionne');
      }

      await deleteOldValue(ambassadorId);

      try {
        var responsePost = await http.post(
          Uri.parse('${SettingService.leBonCoinsEndpoint()}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'dl': int.parse(_newDLmin),
            'ul': int.parse(_newULmin),
            'ambassadorId': ambassadorId,
            'nombre_test': nombreDeTestsSelectionne,
          }),
        );

        if (kDebugMode) {
          print('API response status code: ${responsePost.statusCode}');
          print('API response body: ${responsePost.body}');
        }
      } catch (error) {
        if (kDebugMode) {
          print('Erreur lors de l\'appel de l\'API : $error');
        }
      }
    }
  }

  Future<void> fetchUlminDlmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ambassadorId = prefs.getString('ambassadorId');

    if (ambassadorId == null || ambassadorId.isEmpty) {
      print('Ambassador ID is missing.');
      return;
    }

    String url = '${SettingService.leBonCoinsEndpoint()}';
    Map<String, String> queryParams = {
      'filter': jsonEncode({
        "where": {"ambassadorId": ambassadorId}
      })
    };

    try {
      var response =
      await http.get(Uri.parse(url).replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          var firstItem = data.first;

          _newDLmin = firstItem['dl'].toString();
          _newULmin = firstItem['ul'].toString();

          ulminController.text = _newULmin;
          dlminController.text = _newDLmin;
        } else {
          print('No data found for the provided ambassador ID.');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ulmin and dlmin: $e');
    }
  }

  Future<Map<String, double>> calculateSpeeds() async {
    print("-------------------test en cours"  );
    await fetchUlminDlmin();
    final downloadSpeed = await calculateDownloadSpeed();
    final uploadSpeed = await calculateUploadSpeed();
    final ping = await measurePing();
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await saveDataHistory(downloadSpeed, uploadSpeed, ping, position.latitude, position.longitude);
    final dlMin = double.tryParse(_newDLmin);
    final ulMin = double.tryParse(_newULmin);
    print("Download Speed: $downloadSpeed Mbps, Upload Speed: $uploadSpeed Mbps");
    print("Minimum Download Speed: $dlMin Mbps, Minimum Upload Speed: $ulMin Mbps");
    if (downloadSpeed < dlMin! || uploadSpeed < ulMin!) {
      print("-------------------test echoué");
    } else {
      await sendSpeedToServerWithMessage();
    }
    return {
      "downloadSpeed": downloadSpeed,
      "uploadSpeed": uploadSpeed,
    };
  }

  final DateTime startTime = DateFormat('HH:mm').parse('07:45');
  final DateTime endTime = DateFormat('HH:mm').parse('18:00');

  int calculateIntervalInMinutes() {
    final DateTime startTime = DateFormat('HH:mm').parse('07:45');
    final DateTime endTime = DateFormat('HH:mm').parse('18:00');

    final int totalAvailableTimeInMinutes =
        endTime.difference(startTime).inMinutes;

    if (nombreDeTestsSelectionne <= 0) {
      return 0;
    }

    final int interval =
        totalAvailableTimeInMinutes ~/ (nombreDeTestsSelectionne - 1);
    print("------------------$interval");

    return interval;
  }

  List<DateTime> calculateTestTimes() {
    List<DateTime> testTimes = [];
    DateTime now = DateTime.now();

    DateTime startTime = DateTime(now.year, now.month, now.day, 7, 45);
    DateTime endTime = DateTime(now.year, now.month, now.day, 18, 0);

    DateTime nextTestTime = startTime;

    int intervalMinutes = calculateIntervalInMinutes();

    for (int i = 0; i < nombreDeTestsSelectionne - 1; i++) {
      if (nextTestTime.isBefore(endTime)) {
        testTimes.add(nextTestTime);
        nextTestTime = nextTestTime.add(Duration(minutes: intervalMinutes));
      } else {
        break;
      }
    }

    if (testTimes.isEmpty || testTimes.last.isBefore(endTime)) {
      testTimes.add(endTime);
    } else {
      testTimes[testTimes.length - 1] = endTime;
    }

    return testTimes;
  }


}

class NetworkService {
  static Future<String> getNetworkType() async {
    NetworkStatus status =
    await NetworkTypeReachability().currentNetworkStatus();
    switch (status) {
      case NetworkStatus.unreachable:
        return 'no connection';
      case NetworkStatus.wifi:
        return 'wifi';
      case NetworkStatus.mobile2G:
        return '2G';
      case NetworkStatus.moblie3G:
        return '3G';
      case NetworkStatus.moblie4G:
        return '4G';
      case NetworkStatus.moblie5G:
        return '5G';
      case NetworkStatus.otherMoblie:
        return 'other mobile';
      default:
        return 'unknown';
    }
  }
}

