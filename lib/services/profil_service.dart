import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilService {
  static const String baseUrl = 'https://qosambassadors.herokuapp.com';
  static const String ambassadorsEndpoint = '$baseUrl/ambassadors';

  static Future<Map<String, dynamic>?> getUserProfile(String ambassadorId) async {
    try {
      final response = await http.get(
        Uri.parse('$ambassadorsEndpoint/$ambassadorId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP Error! Status: ${response.statusCode}');
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

  static Future<bool> updateUserProfile(String ambassadorId, String newPrenom, String newNom) async {
    try {
      final response = await http.patch(
        Uri.parse('$ambassadorsEndpoint/$ambassadorId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'prenom': newPrenom,
          'nom': newNom,
        }),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('HTTP Error! Status: ${response.statusCode}');
        }
        return false;
      }

      return true;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }

  Future<dynamic> get(String url, Map<String, dynamic> params) async {
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
        throw Exception('HTTP Error! Status: ${response.statusCode}');
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

  Future<Map<String, dynamic>?> patch(String url, Map<String, dynamic> data) async {
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
          print('HTTP Error! Status: ${response.statusCode}');
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
}
