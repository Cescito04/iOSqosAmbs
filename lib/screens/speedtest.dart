import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cell_info/CellResponse.dart';
import 'package:flutter_cell_info/SIMInfoResponse.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:flutter_cell_info/models/common/cell_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:network_type_reachability/network_type_reachability.dart';
import 'package:qosambassadors/screens/home.dart';
import 'package:qosambassadors/services/image_service.dart';
import 'package:qosambassadors/services/services.dart';
import 'package:qosambassadors/services/speed_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ipwhois/ipwhois.dart';
import 'package:dart_ping/dart_ping.dart';
import '../services/cell_service.dart';
import 'dart:io';

class SpeedTest extends StatefulWidget {
  const SpeedTest({Key? key}) : super(key: key);

  @override
  _SpeedTestState createState() => _SpeedTestState();
}

class _SpeedTestState extends State<SpeedTest>
    with SingleTickerProviderStateMixin {
  late StreamController<double> _speedController;
  bool isDownloading = false;
  bool isUploading = false;
  double value = 0;
  String dlSpeedValue = '_';
  String ulSpeedValue = '_';
  String connTypeValue = '_';
  CellType? currentCellInFirstChip;

  String pingValue = '_';
  List<Map<String, dynamic>> testResults = [];
  late AnimationController _animationController;
  Color colorSpeed = const Color(0xFFD3D3D3);
  DateTime currentDate = DateTime.now();
  Home home = Home();
  bool isTestRunning = false;
  bool _isExpanded = false;
  IpInfo? _ipInfo;
  IpInfo? _ipInfoV6;

  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  bool _isServerSelectionInProgress = false;
  late Timer _timer;

  String? _ip;
  String? _asn;
  String? _isp;
  //latitude
  String? _latitude;
  //longitude
  String? _longitude;
  String? _organisation;
  String? currentDBM;
  String? _countrycode;
  String? _regioncode;
  CellsResponse? _cellsResponse;

  String _unitText = 'Mbps';
  String simDisplayName = 'Test de vitesse';
  CellService _cellService = CellService();
  int cid = 0;
  int tac = 0;
  int lac = 0;
  int nci = 0;
  int eNb = 0;
  int rssi = 0;
  int bandName = 0;
  int ecgi = 0;
  double rsrp = 0;
  int rsrq = 0;
  int cqi = 0;
  double snr = 0;
  int ta = 0;
  int band = 0;
  int pci = 0;
  int arfcn = 0;
  int channelNumber = 0;
  int mcc = 0;
  int mnc = 0;

  bool isNRnetwork = false;
  bool _downloadComplete = false;
  bool _uploadComplete = false;
  String info = '';

  int dlfrequency = 0;
  int bandNumber = 0;
  double psc = 0;
  int dbm = 0;
  int csirsrq = 0;
  int csirsrpasu = 0;
  int csisinr = 0;
  int ssrsrp = 0;
  int ssrsrq = 0;
  int sssinr = 0;
  int ssrsrpasu = 0;

  int timingAdvance = 0;
  int bandwidth = 0;
  int rnc = 0;
  int cgi = 0;
  int ci = 0;
  int rssiAsu = 0;
  int ecio = 0;
  int rscp = 0;
  int rscpAsu = 0;
  int darfcn = 0;
  List<double> downloadRates = [];
  List<double> uploadRates = [];
  double averageDownloadRate = 0;
  double averageUploadRate = 0;
  double maxDownloadRate = 0;
  double maxUploadRate = 0;

  String cellule = '';
  String networkType = 'Unknown';
  @override
  void initState() {
    super.initState();
    _speedController = StreamController<double>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    initPlatformState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      initPlatformState();
     getNetworkType();
    });
    getMyIpInfo();
    fetchNetworkInfo();
    measurePing();
    _getCurrentNetworkStatus();
    getNetworkType();
  }

  @override
  void dispose() {
    _speedController.close();
    _animationController.dispose();
    super.dispose();
  }

  void reset() {
    setState(() {
      connTypeValue = '_';
      pingValue = '_';
      dlSpeedValue = '_';
      ulSpeedValue = '_';
      _animationController.reset();
      _speedController.add(0.0);

      _testInProgress = false;
      _downloadRate = 0;
      _uploadRate = 0;
      _downloadProgress = '0';
      _uploadProgress = '0';
      _unitText = 'Mbps';
      _downloadCompletionTime = 0;
      _uploadCompletionTime = 0;
      bool _downloadComplete = false;
      bool _uploadComplete = false;


      _asn = null;
      _isp = null;
      _ip = null;
    });
  }

  String _networkTypeStatic = 'Unknown';

  _getCurrentNetworkStatus() async {
    if (Platform.isAndroid) {
      await NetworkTypeReachability().getPermisionsAndroid;
    }
    NetworkStatus status =
        await NetworkTypeReachability().currentNetworkStatus();
    setState(() {
      _networkTypeStatic = status.toString();
    });
  }

  String ambassadorId = '';

  void saveDataHistory() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ambassadorId = prefs.getString('ambassadorId') ?? "";

      String url = Services().historyUrl();
      Map<String, dynamic> data = {
        "techno": connTypeValue,
        "ping": double.parse(pingValue),
        "download": double.parse(dlSpeedValue),
        "upload": double.parse(ulSpeedValue),
        "dlmax": maxDownloadRate,
        "ulmax": maxUploadRate,
        "dlmoy": averageDownloadRate,
        "ulmoy": averageUploadRate,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "ambassadorId": ambassadorId,
        "date": _getCurrentFormattedDate(),
        "type": "manuel"
      };
      if (networkType != 'wifi') {
        data.addAll({
          "cellule": cellule,
          "cid": cid,
          "tac": tac,
          "lac": lac,
          "nci": nci,
          "eNb": eNb,
          "rssi": rssi,
          "bandName": bandName,
          "ecgi": ecgi,
          "rsrp": rsrp,
          "rsrq": rsrq,
          "cqi": cqi,
          "snr": snr,
          "ta": ta,
          "band": band,
          "pci": pci,
          "arfcn": arfcn,
          "channelNumber": channelNumber,
          "mcc": mcc,
          "mnc": mnc,
          "rssiasu": rssiAsu,
          "ecio": ecio,
          "rscp": rscp,
          "rscpasu": rscpAsu,
          "rnc": rnc,
          "cgi": cgi,
          "ci": ci,
          "timingAdvance": timingAdvance,
          "bandwidth": bandwidth,
          "dlfrequency": dlfrequency,
          "bandNumber": bandNumber,
          "csirsrq": csirsrq,
          "csirsrpasu": csirsrpasu,
          "csisinr": csisinr,
          "ssrsrp": ssrsrp,
          "ssrsrq": ssrsrq,
          "sssinr": sssinr,
          "ssrsrpasu": ssrsrpasu,
          "darfcn": darfcn,
          "dbm": dbm,
          "psc": psc,
        });
      }

      final response = await SpeedService.post(url, data);

      if (kDebugMode) {
        print("response : $response");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during data processing: $e");
      }
    }
  }

  String _getCurrentFormattedDate() {
    return currentDate.toIso8601String();
  }

  getNetworkType() async {
    NetworkStatus status =
        await NetworkTypeReachability().currentNetworkStatus();
    switch (status) {
      case NetworkStatus.unreachable:
        networkType = 'No Connection';
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
        if (isNRnetwork)
          networkType = '5G';
        else
          networkType = '4G';
        break;
      case NetworkStatus.moblie5G:
        networkType = '5G';
        break;
      case NetworkStatus.otherMoblie:
        networkType = 'Mobile';
        break;
    }

    setState(() {
      connTypeValue = networkType;
    });
  }

  Future<void> fetchNetworkInfo() async {
    IpInfo? ipInfo = await getMyIpInfo();
    if (ipInfo != null) {
      setState(() {
        _ip = ipInfo.ip;
        _organisation = ipInfo.organization;
        _countrycode = ipInfo.countryCode;
        _regioncode = ipInfo.regionCode;
      });
    }
  }

  void handleTest(String testType, String pingValue, String downloadValue,
      String uploadValue) {
    final newResult = {
      'type': testType,
      'ping': pingValue,
      'download': downloadValue,
      'upload': uploadValue,
    };
    testResults.add(newResult);
  }

  int currentTestVal = 0;

  Future<void> measurePing() async {
    int? _pingSpeed = 0;
    try {
      PingData response = await Ping('8.8.8.8', count: 1).stream.first;
      setState(() {
        _pingSpeed = response.response?.time != null
            ? response.response?.time?.inMilliseconds
            : null;
        pingValue = '$_pingSpeed';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void resetSpeedometer() {
    setState(() {
      value = 0;
      _animationController.reset();
      _speedController.add(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> dbmItems = currentDBM
            ?.split('\n')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList() ??
        [];
    // print (dbmItems);
    List<Map<String, String>> simItems = [
      {'label': 'SIM', 'value': simDisplayName},
    ];
    List<Map<String, String>> ispAsnIpItems = [
      {'label': 'IP', 'value': _ip ?? 'N/A'},
      {'label': 'ASN', 'value': _asn ?? 'N/A'},
    ];

    List<Map<String, String>> parsedDBMItems = dbmItems.map((item) {
      List<String> parts = item.split('=');
      String label = parts[0].trim();
      String value = parts.length > 1 ? parts[1].trim() : '';
      return {'label': label, 'value': value};
    }).toList();
    Map<String, dynamic> lacItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'LAC',
        orElse: () => {'label': 'LAC', 'value': 'Not Found'});
    lac = lacItem['value'] == 'Not Found' ? 0 : int.parse(lacItem['value']);

    Map<String, dynamic> tacItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'TAC',
        orElse: () => {'label': 'TAC', 'value': 'Not Found'});
    tac = tacItem['value'] == 'Not Found' ? 0 : int.parse(tacItem['value']);
    Map<String, dynamic> cidItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CID' || item['label'] == 'CID (8b)',
        orElse: () => {'label': 'CID', 'value': 'Not Found'});
    cid = cidItem['value'] == 'Not Found' ? 0 : int.parse(cidItem['value']);

    Map<String, dynamic> nciItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'NCI',
        orElse: () => {'label': 'NCI', 'value': 'Not Found'});
    nci = nciItem['value'] == 'Not Found' ? 0 : int.parse(nciItem['value']);
    Map<String, dynamic> pscItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'PSC',
        orElse: () => {'label': 'PSC', 'value': 'Not Found'});
    if (pscItem['value'] == 'Not Found' || pscItem['value'] == 'N/A') {
      psc = 0;
    } else {
      try {
        if (pscItem['value'].contains('.')) {
          psc = double.parse(pscItem['value']).round() as double;
        } else {
          psc = int.parse(pscItem['value']) as double;
        }
      } catch (e) {
        print("Error parsing bandwidth value: ${pscItem['value']}");
        psc = 0; // default or error value
      }
    }
    Map<String, dynamic> dbmItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'dbm',
        orElse: () => {'label': 'dbm', 'value': 'Not Found'});
    dbm = dbmItem['value'] == 'Not Found' ? 0 : int.parse(dbmItem['value']);

    Map<String, dynamic> eNbItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'eNb',
        orElse: () => {'label': 'eNb', 'value': 'Not Found'});
    eNb = eNbItem['value'] == 'Not Found' ? 0 : int.parse(eNbItem['value']);
    //rssi
    Map<String, dynamic> rssiItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSSI',
        orElse: () => {'label': 'RSSI', 'value': 'Not Found'});
    rssi = rssiItem['value'] == 'Not Found' ? 0 : int.parse(rssiItem['value']);
    //bandName
    Map<String, dynamic> bandNameItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'Band',
        orElse: () => {'label': 'Band', 'value': 'Not Found'});
    if (bandNameItem['value'] == 'Not Found') {
      bandName = 0;
    } else {
      if (bandNameItem['value'].contains('.')) {
        bandName = double.parse(bandNameItem['value']).round();
      } else {
        bandName = int.tryParse(bandNameItem['value'] ?? '0') ?? 0;
      }
    }

    Map<String, dynamic> ecgiItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'eCGI',
        orElse: () => {'label': 'eCGI', 'value': 'Not Found'});
    ecgi = ecgiItem['value'] == 'Not Found' ? 0 : int.parse(ecgiItem['value']);
    Map<String, dynamic> darfcnItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'darfcn',
        orElse: () => {'label': 'eCGI', 'value': 'Not Found'});
    darfcn =
        darfcnItem['value'] == 'Not Found' ? 0 : int.parse(darfcnItem['value']);
    Map<String, dynamic> rsrpItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSRP',
        orElse: () => {'label': 'RSRP', 'value': 'Not Found'});
    rsrp =
        rsrpItem['value'] == 'Not Found' ? 0 : double.parse(rsrpItem['value']);

    Map<String, dynamic> rsrqItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSRQ',
        orElse: () => {'label': 'RSRQ', 'value': 'Not Found'});
    if (rsrqItem['value'] == 'Not Found') {
      rsrq = 0;
    } else {
      if (rsrqItem['value'].contains('.')) {
        rsrq = double.parse(rsrqItem['value']).round();
      } else {
        rsrq = int.parse(rsrqItem['value']);
      }
    }
    //cqi
    Map<String, dynamic> cqiItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CQI',
        orElse: () => {'label': 'CQI', 'value': 'Not Found'});
    cqi = cqiItem['value'] == 'Not Found' ? 0 : int.parse(cqiItem['value']);
    //snr
    Map<String, dynamic> snrItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'SNR',
        orElse: () => {'label': 'SNR', 'value': 'Not Found'});
    snr = snrItem['value'] == 'Not Found' ? 0 : double.parse(snrItem['value']);

    //ta
    Map<String, dynamic> taItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'TA',
        orElse: () => {'label': 'TA', 'value': 'Not Found'});
    ta = taItem['value'] == 'Not Found' ? 0 : int.parse(taItem['value']);
    //band
    Map<String, dynamic> bandItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'Band',
        orElse: () => {'label': 'Band', 'value': 'Not Found'});
    if (bandItem['value'] == 'Not Found') {
      band = 0;
    } else {
      if (bandItem['value'].contains('.')) {
        band = double.parse(bandItem['value']).round();
      } else {
        band = int.tryParse(bandItem['value'] ?? '0') ?? 0;
      }
    }
    Map<String, dynamic> pciItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'PCI',
        orElse: () => {'label': 'PCI', 'value': 'Not Found'});
    pci = pciItem['value'] == 'Not Found' ? 0 : int.parse(pciItem['value']);
    Map<String, dynamic> arfcnItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'ARFCN',
        orElse: () => {'label': 'ARFCN', 'value': 'Not Found'});
    arfcn =
        arfcnItem['value'] == 'Not Found' ? 0 : int.parse(arfcnItem['value']);
    //channelNumber
    Map<String, dynamic> channelNumberItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'Channel Number',
        orElse: () => {'label': 'Channel Number', 'value': 'Not Found'});
    channelNumber = channelNumberItem['value'] == 'Not Found'
        ? 0
        : int.parse(channelNumberItem['value']);
    //mcc
    Map<String, dynamic> mccItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'MCC',
        orElse: () => {'label': 'MCC', 'value': 'Not Found'});
    mcc = mccItem['value'] == 'Not Found' ? 0 : int.parse(mccItem['value']);
    //mnc
    Map<String, dynamic> mncItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'MNC',
        orElse: () => {'label': 'MNC', 'value': 'Not Found'});
    mnc = mncItem['value'] == 'Not Found' ? 0 : int.parse(mncItem['value']);
    //pci

    Map<String, dynamic> dlFrequencyItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'DL Frequency',
        orElse: () => {'label': 'DL Frequency', 'value': 'Not Found'});
    dlfrequency = dlFrequencyItem['value'] == 'Not Found'
        ? 0
        : int.parse(dlFrequencyItem['value']);
    Map<String, dynamic> bandNumberItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'BandNumber',
        orElse: () => {'label': 'BandNumber', 'value': 'Not Found'});
    bandNumber = bandNumberItem['value'] == 'Not Found'
        ? 0
        : int.parse(bandNumberItem['value']);
    Map<String, dynamic> csirsrqItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CSI RSRQ',
        orElse: () => {'label': 'CSI RSRQ', 'value': 'Not Found'});
    csirsrq = csirsrqItem['value'] == 'Not Found'
        ? 0
        : int.parse(csirsrqItem['value']);
    //csirsrpasu
    Map<String, dynamic> csirsrpasuItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CSI RSRP ASU',
        orElse: () => {'label': 'CSI RSRP ASU', 'value': 'Not Found'});
    csirsrpasu = csirsrpasuItem['value'] == 'Not Found'
        ? 0
        : int.parse(csirsrpasuItem['value']);
    //csisinr
    Map<String, dynamic> csisinrItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CSI SINR',
        orElse: () => {'label': 'CSI SINR', 'value': 'Not Found'});
    csisinr = csisinrItem['value'] == 'Not Found'
        ? 0
        : int.parse(csisinrItem['value']);
    //ssrsrp
    Map<String, dynamic> ssrsrpItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'SS RSRP',
        orElse: () => {'label': 'SS RSRP', 'value': 'Not Found'});
    ssrsrp =
        ssrsrpItem['value'] == 'Not Found' ? 0 : int.parse(ssrsrpItem['value']);
    //ssrsrq
    Map<String, dynamic> ssrsrqItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'SS RSRQ',
        orElse: () => {'label': 'SS RSRQ', 'value': 'Not Found'});
    ssrsrq =
        ssrsrqItem['value'] == 'Not Found' ? 0 : int.parse(ssrsrqItem['value']);
    //sssinr
    Map<String, dynamic> sssinrItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'SS SINR',
        orElse: () => {'label': 'SS SINR', 'value': 'Not Found'});
    sssinr =
        sssinrItem['value'] == 'Not Found' ? 0 : int.parse(sssinrItem['value']);
    //ssrsrpasu
    Map<String, dynamic> ssrsrpasuItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'SS RSRP ASU',
        orElse: () => {'label': 'SS RSRP ASU', 'value': 'Not Found'});
    ssrsrpasu = ssrsrpasuItem['value'] == 'Not Found'
        ? 0
        : int.parse(ssrsrpasuItem['value']);
    //timingAdvance
    Map<String, dynamic> timingAdvanceItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'Timing Advance',
        orElse: () => {'label': 'Timing Advance', 'value': 'Not Found'});
    timingAdvance = timingAdvanceItem['value'] == 'Not Found'
        ? 0
        : int.parse(timingAdvanceItem['value']);

    //bandwidth
    Map<String, dynamic> bandwidthItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'Bandwidth',
        orElse: () => {'label': 'Bandwidth', 'value': 'Not Found'});
    if (bandwidthItem['value'] == 'Not Found' ||
        bandwidthItem['value'] == 'N/A') {
      bandwidth = 0;
    } else {
      try {
        if (bandwidthItem['value'].contains('.')) {
          bandwidth = double.parse(bandwidthItem['value']).round();
        } else {
          bandwidth = int.parse(bandwidthItem['value']);
        }
      } catch (e) {
        print("Error parsing bandwidth value: ${bandwidthItem['value']}");
        bandwidth = 0; // default or error value
      }
    }

    //rnc
    Map<String, dynamic> rncItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RNC',
        orElse: () => {'label': 'RNC', 'value': 'Not Found'});
    rnc = rncItem['value'] == 'Not Found' ? 0 : int.parse(rncItem['value']);
    //cgi
    Map<String, dynamic> cgiItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CGI',
        orElse: () => {'label': 'CGI', 'value': 'Not Found'});
    cgi = cgiItem['value'] == 'Not Found' ? 0 : int.parse(cgiItem['value']);
    //ci
    Map<String, dynamic> ciItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'CI',
        orElse: () => {'label': 'CI', 'value': 'Not Found'});
    ci = ciItem['value'] == 'Not Found' ? 0 : int.parse(ciItem['value']);
    //rssiAsu
    Map<String, dynamic> rssiAsuItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSSIASU',
        orElse: () => {'label': 'RSSIASU', 'value': 'Not Found'});

// Utilisation de tryParse pour éviter les exceptions et fournir une gestion d'erreur claire
    int? rssiAsu = int.tryParse(rssiAsuItem['value']?.toString() ?? '');

    if (rssiAsu == null) {
      // Logique d'erreur ou de gestion de valeur non numérique
      print("Erreur de parsing pour RSSIASU: valeur non numérique ou absente.");
      rssiAsu =
          0; // Attribuer une valeur par défaut ou gérer l'erreur comme nécessaire
    }

    //ecio
    Map<String, dynamic> ecioItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'ECIO',
        orElse: () => {'label': 'ECIO', 'value': 'Not Found'});
    ecio = ecioItem['value'] == 'Not Found' ? 0 : int.parse(ecioItem['value']);
    //rscp
    Map<String, dynamic> rscpItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSCP',
        orElse: () => {'label': 'RSCP', 'value': 'Not Found'});
    rscp = rscpItem['value'] == 'Not Found' ? 0 : int.parse(rscpItem['value']);
    //rscpAsu
    Map<String, dynamic> rscpAsuItem = parsedDBMItems.firstWhere(
        (item) => item['label'] == 'RSCPASU',
        orElse: () => {'label': 'RSCPASU', 'value': 'Not Found'});
    rscpAsu = rscpAsuItem['value'] == 'Not Found'
        ? 0
        : int.parse(rscpAsuItem['value']);

    List<Map<String, String>> ispAsnPingTechnoItems = [
      {'label': 'Opérateur', 'value': simDisplayName},
      {'label': 'Techno', 'value': connTypeValue},
      {'label': 'Cellule', 'value': cellule},
      {'label': 'Ping', 'value': pingValue},
    ];
    List<Map<String, String>> wifiItems = [
      {'label': 'Techno', 'value': connTypeValue},
      {'label': 'Ping', 'value': pingValue},
    ];

    List<Map<String, String>> combinedItems = [
      ...ispAsnPingTechnoItems,
      ...parsedDBMItems,
      ...ispAsnIpItems,
    ];

    int visibleCount = _isExpanded ? combinedItems.length : 3;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Test de vitesse"),
          //return icon
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                networkType != 'wifi'
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 5,
                          childAspectRatio: 2,
                        ),
                        itemCount: visibleCount,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, String> item = combinedItems[index];
                          return buildGridItem(item);
                        },
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              wifiItems.length <= 2 ? wifiItems.length : 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 5,
                          childAspectRatio: wifiItems.length <= 2 ? 3 : 2,
                        ),
                        itemCount: wifiItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, String> item = wifiItems[index];
                          // Apply margins only to the left and right
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 30), // Horizontal margin
                            child: buildGridItem(item),
                          );
                        },
                      ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.orange,
                  ),
                  child: networkType == "wifi"
                      ? null
                      : IconButton(
                          icon: Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                ),
                StreamBuilder<double>(
                  stream: _speedController.stream,
                  builder: (context, snapshot) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildProgressIndicatorSection(
                                'Download',
                                _downloadProgress,
                                _downloadRate,
                                _unitText,                                Colors.red,
                                averageDownloadRate,
                                maxDownloadRate,
                                  _testInProgress
                              ),
                              buildProgressIndicatorSection(
                                'Upload',
                                _uploadProgress,
                                _uploadRate,
                                _unitText,
                                Colors.green,
                                averageUploadRate,
                                maxUploadRate,
                                  _testInProgress
                              ),

                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                buildActionButton(),
                SizedBox(height: 5),
                if (networkType != "wifi") ...[
                  Text(
                    "Cliquez sur la carte pour voir l'emplacement du site",
                    style: TextStyle(color: Colors.grey),
                  ),
                  InkWell(
                      onTap: () async {
                        await openGoogleMaps(double.parse(_latitude ?? '0'),
                            double.parse(_longitude ?? '0'));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Card(
                                elevation: 0,
                                child: Image(
                                  image: ImageService.getImageAsset('maps.png'),
                                  fit: BoxFit.cover,
                                ))),
                      )),
                ],

                //Text('NETWORK_TYPE Static: $_networkTypeStatic'),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridItem(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        showInfoDialog(context, item['value'] ?? '');
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border(top: BorderSide(color: Colors.orange)),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child:
                    Text(item['value'] ?? '', style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
          Positioned(
            top: -3,
            left: 13,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              color: Theme.of(context).canvasColor,
              child: Text(item['label'] ?? '',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressIndicatorSection(
      String title,
      String progress,
      double rate,
      String unit,
      Color color,
      double averageRate,
      double maxRate,
      bool isTestInProgress,
      ) {
    double progressValue = progress.isNotEmpty ? double.parse(progress) / 100 : 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Stack(
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.transparent,
                  color: color,
                  minHeight: 20,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "${(progressValue * 100).toStringAsFixed(0)}%", // Display the percentage
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
              if (isTestInProgress) ...[
        Text('$rate $unit'),      ],

        if (!isTestInProgress) ...[
          Text('Moyenne: ${averageRate.toStringAsFixed(2)} $unit'),
          Text('Max: ${maxRate.toStringAsFixed(2)} $unit'),
        ],
      ],
    );
  }

  Widget buildActionButton() {
    if (!_testInProgress) {
      return ElevatedButton(
        onPressed: () {
          _timer.cancel();
          _startTesting();
          _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
            initPlatformState();
            getNetworkType();
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text('Démarrer'),
      );
    } else {
      return Column(
        children: [
          CircularProgressIndicator(
            color: Colors.orange,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
                onPressed: _cancelTest,
                icon: const Icon(Icons.cancel_rounded, color: Colors.orange),
                label: const Text('Annuler',
                    style: TextStyle(color: Colors.orange))),
          ),
        ],
      );
    }
  }

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    var googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  void _startTesting() async {
    reset();
    _setTestInProgress(true);
    await measurePing();
    try {
      await runInternetSpeedTest();
    } catch (e) {
      if (kDebugMode) {
        print('Error during speed test: $e');
      }
      reset();
    }
  }

  void _cancelTest() {
    internetSpeedTest.cancelTest();
    reset();
  }

  void checkTestsCompleted() {
    if (_downloadComplete && _uploadComplete) {
      _setTestInProgress(false);
    }
  }

  void _setTestInProgress(bool inProgress) {
    setState(() {
      _testInProgress = inProgress;
      _downloadComplete = false;
      _uploadComplete = false;
    });
  }

  void _updateProgress(TestResult data, double percent) {
    setState(() {
      _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      if (data.type == TestType.download) {
        _downloadRate = data.transferRate;
        _downloadProgress = percent.toStringAsFixed(2);
        downloadRates.add(data.transferRate);
      } else {
        _uploadRate = data.transferRate;
        _uploadProgress = percent.toStringAsFixed(2);
        uploadRates.add(data.transferRate);
      }
    });
  }

  Future<void> runInternetSpeedTest() async {
    await internetSpeedTest.startTesting(
      useFastApi: true,
      onStarted: () {},
      onCompleted: _onTestCompleted,
      onProgress: (double percent, TestResult data) => _updateProgress(data, percent),
      onError: (String errorMessage, String speedTestError) {
        if (kDebugMode) {
          print('the errorMessage $errorMessage, the speedTestError $speedTestError');
        }
        reset();
      },
      onDefaultServerSelectionInProgress: () {
        setState(() {
          _isServerSelectionInProgress = true;
        });
      },
      onDefaultServerSelectionDone: (Client? client) {
        setState(() {
          _isServerSelectionInProgress = false;
          _ip = client?.ip;
          _asn = client?.asn;
          _isp = client?.isp;
        });
      },
      onDownloadComplete: (TestResult data) {
        _handleDownloadComplete(data);
        checkTestsCompleted();
      },
      onUploadComplete: (TestResult data) {
        _handleUploadComplete(data);
        checkTestsCompleted();
      },
      onCancel: () {
        reset();
      },
    );
  }

  void _onTestCompleted(TestResult download, TestResult upload) {
    setState(() {
      _downloadRate = download.transferRate;
      _uploadRate = upload.transferRate;
      _unitText = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
      _downloadProgress = '100';
      _uploadProgress = '100';
      _downloadCompletionTime = download.durationInMillis;
      _uploadCompletionTime = upload.durationInMillis;
      dlSpeedValue = download.transferRate.toStringAsFixed(0);
      ulSpeedValue = upload.transferRate.toStringAsFixed(0);
      _testInProgress = false;
    });
    saveDataHistory();
    if (kDebugMode) {
      print("----------------------------------");
      print("$uploadRates");
      print("Data saved successfully. Average Download: $averageDownloadRate, Max Download: $maxDownloadRate, Average Upload: $averageUploadRate, Max Upload: $maxUploadRate");
    }
  }

  void _handleDownloadComplete(TestResult data) {
    setState(() {
      averageDownloadRate = downloadRates.reduce((a, b) => a + b) / downloadRates.length;
      maxDownloadRate = downloadRates.reduce(math.max);
      _downloadComplete = true;
    });
  }

  void _handleUploadComplete(TestResult data) {
    setState(() {
      averageUploadRate = uploadRates.reduce((a, b) => a + b) / uploadRates.length;
      maxUploadRate = uploadRates.reduce(math.max);
      _uploadComplete = true;
    });
  }

  Future<CellType?> getNRinNeighboring(cellsResponse) async {
    try {
      CellType? nrCell;
      cellsResponse.neighboringCellList.forEach((c) {
        if (c.type == "NR") {
          nrCell = c as CellType;
        }
      });
      return nrCell;
    } catch (e) {
      throw Exception("Error occurred while getting NR cell: $e");
    }
  }

  Future<void> initPlatformState() async {
    isNRnetwork = false;
    CellsResponse? cellsResponse;

    try {
      String? platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion!);

      cellsResponse = CellsResponse.fromJson(body);

      CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
      String info = "";

      if (currentCellInFirstChip.type == "LTE") {
        CellType? nrCellInFirstChip = await getNRinNeighboring(cellsResponse);
        //print("-------------------");
        //print(nrCellInFirstChip.nr);
        if (nrCellInFirstChip != null) {
          isNRnetwork = true;
          info += "PCI = ${nrCellInFirstChip.nr?.pci ?? 'N/A'}\n";
          info +=
              "RSRP = ${nrCellInFirstChip.nr?.signalNR?.csiRsrp ?? 'N/A'}\n";
          info +=
              "RSRQ = ${nrCellInFirstChip.nr?.signalNR?.csiRsrq ?? 'N/A'}\n";
          info += "Band = ${nrCellInFirstChip.nr?.bandNR?.name ?? 'N/A'}";
          info +=
              "ARFCN = ${nrCellInFirstChip.nr?.bandNR?.downlinkArfcn ?? 'N/A'}\n";
          info +=
              "DLFrequence = ${nrCellInFirstChip.nr?.bandNR?.downlinkFrequency ?? 'N/A'}\n";
          info +=
              "BandNumber = ${nrCellInFirstChip.nr?.bandNR?.number ?? 'N/A'}\n";
          info += "BandName = ${nrCellInFirstChip.nr?.bandNR?.name ?? 'N/A'}\n";
          info +=
              "Channel Number = ${nrCellInFirstChip.nr?.bandNR?.channelNumber ?? 'N/A'}\n";
          info += "TAC = ${nrCellInFirstChip.nr?.tac ?? 'N/A'}\n";
          info += "NCI = ${nrCellInFirstChip.nr?.nci ?? 'N/A'}\n";
          info += "DBM = ${nrCellInFirstChip.nr?.signalNR?.dbm ?? 'N/A'}\n";
          info +=
              "CSIRSRQ = ${nrCellInFirstChip.nr?.signalNR?.csiRsrq ?? 'N/A'}\n";
          info +=
              "CSIRSRPASU = ${nrCellInFirstChip.nr?.signalNR?.csiRsrpAsu ?? 'N/A'}\n";
          info +=
              "CSISINR = ${nrCellInFirstChip.nr?.signalNR?.csiSinr ?? 'N/A'}\n";
          info +=
              "SSRSRP = ${nrCellInFirstChip.nr?.signalNR?.ssRsrp ?? 'N/A'}\n";
          info +=
              "SSRSRQ = ${nrCellInFirstChip.nr?.signalNR?.ssRsrq ?? 'N/A'}\n";
          info +=
              "SSSINR = ${nrCellInFirstChip.nr?.signalNR?.ssSinr ?? 'N/A'}\n";
          info +=
              "SSRSRPASU = ${nrCellInFirstChip.nr?.signalNR?.ssRsrpAsu ?? 'N/A'}\n";
        } else {
          info += "eCGI = ${currentCellInFirstChip.lte?.ecgi ?? 'N/A'}\n";
          info += "CID (8b) = ${currentCellInFirstChip.lte?.cid ?? 'N/A'}\n";
          info += "eNb = ${currentCellInFirstChip.lte?.enb ?? 'N/A'}\n";
          info +=
              "RSSI = ${currentCellInFirstChip.lte?.signalLTE?.rssi ?? 'N/A'}\n";
          info +=
              "RSRP = ${currentCellInFirstChip.lte?.signalLTE?.rsrp ?? 'N/A'}\n";
          info +=
              "RSRQ = ${currentCellInFirstChip.lte?.signalLTE?.rsrq ?? 'N/A'}\n";
          info +=
              "CQI = ${currentCellInFirstChip.lte?.signalLTE?.cqi ?? 'N/A'}\n";
          info +=
              "SNR = ${currentCellInFirstChip.lte?.signalLTE?.snr ?? 'N/A'}\n";
          info +=
              "TA= ${currentCellInFirstChip.lte?.signalLTE?.timingAdvance}\n";
          info += "TAC = ${currentCellInFirstChip.lte?.tac ?? 'N/A'}\n";
          info +=
              "Band = ${currentCellInFirstChip.lte?.bandLTE?.name ?? 'N/A'}\n";
          info +=
              "Bandwidth = ${currentCellInFirstChip.lte?.bandwidth ?? 'N/A'}\n";
          info += "PCI = ${currentCellInFirstChip.lte?.pci ?? 'N/A'}\n";
          info +=
              "ARFCN = ${currentCellInFirstChip.lte?.bandLTE?.downlinkEarfcn ?? 'N/A'}\n";
          info +=
              "Channel Number = ${currentCellInFirstChip.lte?.bandLTE?.channelNumber ?? 'N/A'}\n";
          info +=
              "BandNumber = ${currentCellInFirstChip.lte?.bandLTE?.number ?? 'N/A'}\n";
          info +=
              "BandName = ${currentCellInFirstChip.lte?.bandLTE?.name ?? 'N/A'}\n";
        }
      }
      if (currentCellInFirstChip.type == "GSM") {
        info += "CID = ${currentCellInFirstChip.gsm?.cid ?? 'N/A'}\n";
        info += "LAC = ${currentCellInFirstChip.gsm?.lac ?? 'N/A'}\n";
        info +=
            "RSSI = ${currentCellInFirstChip.gsm?.signalGSM?.rssi ?? 'N/A'}\n";
        info += "Band = ${currentCellInFirstChip.gsm?.bandGSM ?? 'N/A'}";
        info +=
            "ARFCN = ${currentCellInFirstChip.gsm?.bandGSM?.arfcn ?? 'N/A'}\n";
      }
      if (currentCellInFirstChip.type == "WCDMA") {
        info += "CID = ${currentCellInFirstChip.wcdma?.cid ?? 'N/A'}\n";
        info += "LAC = ${currentCellInFirstChip.wcdma?.lac ?? 'N/A'}\n";
        info +=
            "RSSI = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rssi ?? 'N/A'}\n";
        info +=
            "Band = ${currentCellInFirstChip.wcdma?.bandWCDMA?.name ?? 'N/A'}\n";
        info += "PSC = ${currentCellInFirstChip.wcdma?.psc ?? 'N/A'}\n";
        info +=
            "DARFCN = ${currentCellInFirstChip.wcdma?.bandWCDMA?.downlinkUarfcn ?? 'N/A'}\n";
        info +=
            "BandNumber = ${currentCellInFirstChip.wcdma?.bandWCDMA?.number ?? 'N/A'}\n";
        info +=
            "BandName = ${currentCellInFirstChip.wcdma?.bandWCDMA?.name ?? 'N/A'}\n";
        info +=
            "Channel Number = ${currentCellInFirstChip.wcdma?.bandWCDMA?.channelNumber ?? 'N/A'}\n";
        info += "RNC = ${currentCellInFirstChip.wcdma?.rnc ?? 'N/A'}\n";
        info += "CGI = ${currentCellInFirstChip.wcdma?.cgi ?? 'N/A'}\n";
        info += "CI = ${currentCellInFirstChip.wcdma?.ci ?? 'N/A'}\n";
        info +=
            "RSSI = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rssi ?? 'N/A'}\n";
        info +=
            "RSSIASU = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rssiAsu ?? 'N/A'}\n";
        info +=
            "dbm = ${currentCellInFirstChip.wcdma?.signalWCDMA?.dbm ?? 'N/A'}\n";
        info +=
            "ECIO = ${currentCellInFirstChip.wcdma?.signalWCDMA?.ecio ?? 'N/A'}\n";
        info +=
            "RSCP = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rscp ?? 'N/A'}\n";
        info +=
            "RSCPASU = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rscpAsu ?? 'N/A'}\n";
      }
      currentDBM = info;
    } on PlatformException {
      _cellsResponse = null;
      print('Failed to get cell info.');
    }

    String? simInfo = await CellInfo.getSIMInfo;
    final simJson = json.decode(simInfo!);
    SIMInfoResponse simInfoResponse = SIMInfoResponse.fromJson(simJson);
    if (simInfoResponse.simInfoList != null &&
        simInfoResponse.simInfoList!.isNotEmpty) {
      simDisplayName =
          simInfoResponse.simInfoList![0].displayName ?? 'Test de vitesse';
    }

    if (!mounted) return;

    setState(() {
      _cellsResponse = cellsResponse;
    });
    String? platformVersion = await CellInfo.getCellInfo;
    final body = json.decode(platformVersion!);

    cellsResponse = CellsResponse.fromJson(body);
    CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];

    getNetworkType();

    if (currentCellInFirstChip.type == "LTE") {
      if (isNRnetwork) {
        cellule = await CellService.fetchCells5GByCidTac(nci, tac);
        Map<String, String> location =
            await CellService.fetchCells5GByCidTacLocation(nci, tac);
        _latitude = location['latitude'];
        _longitude = location['longitude'];
      } else {
        cellule = await CellService.fetchCells4GByCidTac(eNb, cid, tac);
        Map<String, String> location =
            await CellService.fetchCells4GByCidTacLocation(eNb, cid, tac);
        _latitude = location['latitude'];
        _longitude = location['longitude'];
      }
    } else if (currentCellInFirstChip.type == "GSM") {
      cellule = await CellService.fetchCells2GByCidLac(cid, lac);
      Map<String, String> location =
          await CellService.fetchCells2GByCidLacLocation(cid, lac);
      _latitude = location['latitude'];
      _longitude = location['longitude'];
    } else if (currentCellInFirstChip.type == "WCDMA") {
      cellule = await CellService.fetchCells3GByCidLac(cid, lac);
      Map<String, String> location =
          await CellService.fetchCells3GByCidLacLocation(cid, lac);
      _latitude = location['latitude'];
      _longitude = location['longitude'];
    }
  }

  Timer? timer;

  void startTimer() {
    const oneSec = Duration(seconds: 3);
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      initPlatformState();
      getNetworkType();
    });
  }

  void showInfoDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: Text(' $text'),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
