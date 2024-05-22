import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/historique_service.dart';

class HistoriqueController {
  String ambassadorId = '';
  List<dynamic> testResults = [];

  void setTestResults(List<dynamic> newResults) {
    testResults = newResults;
  }


  Future<void> fetchUserHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ambassadorId = prefs.getString('ambassadorId') ?? "";

    try {
      var res = await HistoriqueService.getUserHistory(ambassadorId);
      if (res != null && res.isNotEmpty) {
        List<dynamic> updatedResults = res.map((result) {
          result['formattedDate'] = _getCurrentFormattedDate();
          return result;
        }).toList();

        setTestResults(updatedResults);
      }
    } catch (error) {
      if (kDebugMode) {
        print("An error occurred during the request: $error");
      }
    }
  }

  Future<void> fetchDataCell() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ambassadorId = prefs.getString('ambassadorId') ?? "";

    try {
      var res = await HistoriqueService.getUserHistory(ambassadorId);
      if (res != null && res.isNotEmpty) {
        List<dynamic> updatedResults = res.map((result) {
          result['formattedDate'] = _getCurrentFormattedDate();
          return result;
        }).toList();

        setTestResults(updatedResults);
      }
    } catch (error) {
      if (kDebugMode) {
        print("An error occurred during the request: $error");
      }
    }
  }



  Future<void> openMap(double latitude, double longitude) async {
    Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    if (await canLaunchUrl(googleMapsUrl )) {
      launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  String _getCurrentFormattedDate() {
    DateTime currentDate = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(currentDate);
  }
}
