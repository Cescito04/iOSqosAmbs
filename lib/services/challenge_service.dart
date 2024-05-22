import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qosambassadors/model/property.dart';

class ChallengeDetailsService {
  static const String baseUrl = 'https://qosambassadors.herokuapp.com';
  static const String ambassadorsEndpoint = '$baseUrl/ambassadors';
  static const String challengesEndpoint = '$baseUrl/challenges';




  static Future<List<Property>> fetchProperties() async {
    final response = await http.get(Uri.parse('$baseUrl/properties'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((property) => Property.fromJson(property)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  static Future<List<dynamic>> fetchSouscriptions(String ambassadorId) async {
    final response = await http.get(Uri.parse('$baseUrl/ambassadors/$ambassadorId/souscriptions'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load subscriptions');
    }
  }

  static Future<String?> createSouscription(String ambassadorId, String challengeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/souscriptions'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'ambassadorId': ambassadorId,
        'challengeId': challengeId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['id'];
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> fetchSavedPropertiesValues(String souscriptionId) async {
    final response = await http.get(Uri.parse('$baseUrl/souscriptions/$souscriptionId/properties-values'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load saved properties values');
    }
  }

  static Future<bool> submitProperties(List<Map<String, dynamic>> propertiesToSubmit) async {
    bool allSuccess = true;
    for (var property in propertiesToSubmit) {
      var requestBody = json.encode(property);
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/properties-values'),
          headers: {"Content-Type": "application/json"},
          body: requestBody,
        );

        if (response.statusCode != 200) {
          allSuccess = false;
        }
      } catch (e) {
        allSuccess = false;
      }
    }
    return allSuccess;
  }

  static const String failedToLoadProperties = 'An exception occurred while fetching saved properties values';
  static const String failedToLoadChallenges = 'Failed to load challenges';
  static const String failedToLoadSubscriptions = 'An exception occurred while creating subscription';
  static const String failedToCreateSubscription = 'Failed to create subscription';
  static const String failedToLoadSavedPropertiesValues = 'Failed to load saved properties values';
  static const String subscriptionMessage = 'Vous participez déjà au ce challenge';

  static const String errorMessage = 'Ce champ ne peut pas être vide';

  List<ClassementEntry> classementList = [
    ClassementEntry(nom: "Moussa", score: 50, rang: 11),
    ClassementEntry(nom: "Mor", score: 100, rang: 1),
    ClassementEntry(nom: "Bassirou", score: 95, rang: 2),
    ClassementEntry(nom: "Jules", score: 90, rang: 3),
    ClassementEntry(nom: "Malick", score: 85, rang: 4),
    ClassementEntry(nom: "Cheikh", score: 80, rang: 5),
    ClassementEntry(nom: "Ousseynou", score: 75, rang: 6),
    ClassementEntry(nom: "MCiss", score: 70, rang: 7),
  ];

}


class ClassementEntry {
  final String nom;
  final int score;
  final int rang;

  ClassementEntry({required this.nom, required this.score, required this.rang});
}


