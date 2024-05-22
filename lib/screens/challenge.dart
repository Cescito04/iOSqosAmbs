import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qosambassadors/screens/shimmer.dart';
import 'package:qosambassadors/services/challenge_service.dart';
import 'dart:async';
import 'dart:typed_data';



import '../controller/challenge_info.dart';
import 'details_challenge.dart';
import 'home.dart';
class Challenge extends StatefulWidget {
  const Challenge({super.key});

  @override
  State<Challenge> createState() => _ChallengeState();
}

class _ChallengeState extends State<Challenge> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  List<ChallengeInfo> _challenges = [];
  bool isLoading = true;
  @override
  void initState() {
    fetchChallenges().then((challengesFromApi) {
      setState(() {
        _challenges = challengesFromApi;
        isLoading = false;
      });
    }).catchError((error) {

      isLoading = false;
    });

    super.initState();
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String.split(',').last);
  }

  Future<List<ChallengeInfo>> fetchChallenges() async {
    final response = await http.get(Uri.parse(ChallengeDetailsService.challengesEndpoint));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ChallengeInfo.fromJson(data)).toList();
    } else {
      throw Exception('${ChallengeDetailsService.failedToLoadChallenges}');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body:          Column(
        children: [
          Expanded(
            child: isLoading
                ? ShimmerDetail()
                : ListView.builder(
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                Uint8List imageBytes = dataFromBase64String(challenge.imagePath);

                return Column(
                  children: [
                    Container(
                      height: 210,
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        elevation: 0, // Remove the elevation to make it flat
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            // Background image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: MemoryImage(imageBytes),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Text content
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    challenge.description,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Card(
                                        elevation: 0,
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            challenge.dates,
                                            style: TextStyle(color: Colors.white, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsChallenge(challenge: _challenges[index]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Card(
                                                color: Color(0xffFF8000),
                                                elevation: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Voir +",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),

        ],
      ),



    );
  }
}