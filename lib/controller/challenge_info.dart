
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
class ChallengeInfo {
  final String challengeId;

  final String title;
  final String dates;
  final String description;
  final String imagePath;

  ChallengeInfo({
    required this.title,
    required this.dates,
    required this.description,
    required this.imagePath,
    required this.challengeId  });

  factory ChallengeInfo.fromJson(Map<String, dynamic> json) {
    String formattedStartDate = _format(json['date_debut']);
    String formattedEndDate = _format(json['date_fin']);
    return ChallengeInfo(
      title: json['nom'],
      dates: "du $formattedStartDate au $formattedEndDate",
      description: json['description'],
      imagePath: json['image'],
      challengeId: json['id'],
    );
  }
}
String _format(String date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('dd/MM').format(dateTime);
  return formattedDate;
}

