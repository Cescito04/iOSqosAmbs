import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SpeedService {
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
        throw Exception('Erreur HTTP ! Statut : ${response.statusCode}');
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

  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('HTTP error! status: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
        throw Exception('HTTP error! status: ${response.statusCode}');
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

  static Future<Map<String, dynamic>?> patch(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('HTTP error! status: ${response.statusCode}');
        }
        return null;
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>> put(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error! status: ${response.statusCode}');
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
