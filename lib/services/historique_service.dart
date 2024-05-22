import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HistoriqueService {
  static const String baseUrl = 'https://qosambassadors.herokuapp.com';
  static const String dataHistoriesEndpoint = '$baseUrl/datahistories';

  static String getUserHistoryUrl(String ambassadorId) {
    return '$dataHistoriesEndpoint?filter={"where": {"ambassadorId": "$ambassadorId"}}';
  }

  static Future<dynamic> getUserHistory(String ambassadorId) async {
    try {
      final String url = getUserHistoryUrl(ambassadorId);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }

  static Future<dynamic> get(String url, Map<String, dynamic> params) async {
    try {
      final Uri uri = Uri.parse(url).replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }

  static Future<dynamic> post(String url, dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }

  static Future<dynamic> put(String url, dynamic body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error! Status: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      rethrow;
    }
  }
}
