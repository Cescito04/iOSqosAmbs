import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthentificationService {
  static const String baseUrl = 'https://qosambassadors.herokuapp.com';
  static const String ambassadorsEndpoint = '$baseUrl/ambassadors';
  static const String sendOTPEndpoint = '$baseUrl/apimanagement/sendOTP';

  static String filteredAmbassadorUrl(String phoneNumber) {
    return '$ambassadorsEndpoint?filter={"where": {"numero": "$phoneNumber"}}';
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
        throw Exception('Erreur HTTP ! Statut : ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
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
        throw Exception('HTTP error! status: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (error) {
      rethrow;
    }
  }

  static String sendOTPUrl(String phoneNumber) {
    return '$sendOTPEndpoint/$phoneNumber';
  }




  static const String phoneNumberLabel = "Numéro de Téléphone";
  static const String enterPhoneNumber = "Entrez votre numéro de téléphone";
  static const String verificationCodeMessage = "Nous vous enverrons un code de vérification";
  static const String invalidPhoneNumberError = "Numéro invalide.Veuillez réessayer.";

  static const String hinText = "Numéro de téléphone";
  static const String buttontext = "Suivant";
}
