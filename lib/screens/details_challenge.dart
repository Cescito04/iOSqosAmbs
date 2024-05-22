import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qosambassadors/services/ranking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qosambassadors/controller/challenge_info.dart';
import 'dart:convert';

import '../model/SubscriptionProperty.dart';
import '../model/property.dart';
import '../services/challenge_service.dart';
import '../services/image_service.dart';

class DetailsChallenge extends StatefulWidget {
  final ChallengeInfo challenge;
  const DetailsChallenge({Key? key, required this.challenge}) : super(key: key);

  @override
  State<DetailsChallenge> createState() => _DetailsChallengeState();
}

class _DetailsChallengeState extends State<DetailsChallenge> {
  bool isLoading = false;
  List<Property> properties = [];
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _controllers = {};
  bool showForm = true;
  Map<String, String> enteredValues = {};
  RankingService rankingService = RankingService();

  String get challengeId => widget.challenge.challengeId;

  @override
  void initState() {
    super.initState();
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    setState(() {
      isLoading = true; // Start loading
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ambassadorId = prefs.getString('ambassadorId') ?? '';

    try {
      List<dynamic> souscriptions = await ChallengeDetailsService.fetchSouscriptions(ambassadorId);
      bool subscriptionExists = souscriptions.any((souscription) => souscription['challengeId'] == challengeId);

      if (subscriptionExists) {
        String souscriptionId = souscriptions.firstWhere((souscription) => souscription['challengeId'] == challengeId)['id'];
        await fetchSavedProperties(souscriptionId);
        // User is subscribed, show subscription values
        setState(() {
          showForm = false;
        });
      } else {
        // User is not subscribed, fetch properties for form
        List<Property> props = await ChallengeDetailsService.fetchProperties();
        setState(() {
          properties = props.where((p) => p.challengeId == challengeId).toList();
          initControllers();
          showForm = true; // Ensure the form is shown
        });
      }
    } catch (e) {
      // Handle exceptions
      print('${ChallengeDetailsService.failedToCreateSubscription}: $e');
    }
    setState(() {
      isLoading = false; // End loading
    });
  }

  Future<void> fetchSavedProperties(String souscriptionId) async {
    try {
      List<dynamic> propertiesValues = await ChallengeDetailsService.fetchSavedPropertiesValues(souscriptionId);
      Map<String, String> newValues = propertiesValues.fold<Map<String, String>>({}, (acc, val) {
        acc[val['key']] = val['value'];
        return acc;
      });
      setState(() {
        enteredValues = newValues;
      });
    } catch (e) {
      print('${ChallengeDetailsService.failedToLoadProperties}: $e');
    }
  }

  void initControllers() {
    properties.forEach((property) {
      _controllers[property.id] = TextEditingController(text: enteredValues[property.key] ?? '');
    });
  }

  Future<void> saveEnteredValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('enteredValues_$challengeId', json.encode(enteredValues));
    await prefs.setBool('isSubscribed_$challengeId', true);
  }

  Future<String?> createSouscription(String ambassadorId, String challengeId) async {
    try {
      final String? souscriptionId = await ChallengeDetailsService.createSouscription(ambassadorId, challengeId);
      return souscriptionId;
    } catch (e) {
      print("${ChallengeDetailsService.failedToLoadSubscriptions}: $e");
      return null;
    }
  }

  Future<void> submitProperties(String souscriptionId) async {
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> propertiesToSubmit = properties.map((property) {
        return SubscriptionProperty(
          id: '',
          key: property.key,
          type: property.type,
          value: _controllers[property.id]!.text,
          propertiesId: property.id,
          souscriptionId: souscriptionId,
        ).toJson();
      }).toList();

      bool allSuccess = await ChallengeDetailsService.submitProperties(propertiesToSubmit);

      if (allSuccess) {
        print("All properties submitted successfully.");
        // Additional success handling code here
      } else {
        print("Failed to submit one or more properties.");
        // Handle failures here
      }
    } else {
      print("Form validation failed.");
    }
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String.split(',').last);
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = dataFromBase64String(widget.challenge.imagePath);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: MemoryImage(imageBytes),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: Color(0xffFF8000)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
            
                              child: Image(
                                  image: ImageService.getImageAsset('calendar.png'),
                                  height: 10,
                                  fit: BoxFit.contain,
                                  color: Color(0xffFF8000)
                              ),
                            ),
                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                // borderRadius: BorderRadius.circular(10),
            
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  widget.challenge.dates,
                                  style: TextStyle( fontSize: 15),
                                ),
                              ),
                            ),
            
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,),
            
            
            
                Align(
                  alignment: Alignment.centerLeft,
            
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${widget.challenge.description}', style: TextStyle(fontSize: 13, )),
                      ],
                    ),
                  ),
                ),
            
                SizedBox(height: 10,),
            
            
            
                _buildBottom(),
            
                SizedBox(height: 20), // Maintain this for spacing before the "Classement" title
                Align(
                  alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("Classement du ${widget.challenge.title} ", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                    )),
                ...rankingService.classementList.map((entry) {
                  Color borderColor = entry.rang == 11 ? Colors.orange : Colors.grey.withOpacity(0.8);
                  Color textColor = entry.rang == 11 ? Colors.orange : Colors.grey;
            
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text('${entry.rang}', style: TextStyle(fontSize: 20, color: textColor)),
                          SizedBox(width: 10),
                          Text(entry.nom, style: TextStyle(fontSize: 20, color: textColor)),
                          Spacer(),
                          Text('${entry.score}', style: TextStyle(fontSize: 20, color: textColor)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                
              ],
            ),
          ),
    );
  }


  Widget _buildBottom() {
    return SizedBox(
      width: double.infinity,
      child: showForm ? _buildCard() : _buildWhiteBackground(),
    );
  }

  Widget _buildCard() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _buildInputField(),
      ),
    );
  }


  Widget _buildWhiteBackground() {
    return Container(
      child: _buildInputField(),
    );
  }


  Widget _buildInputField() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (showForm) ...[
                Text(
                  'Participer au ${widget.challenge.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Remplir ces champs pour continuer',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                SizedBox(
                  height: 10,
                ),
                ...properties.map((property) {
                  _controllers.putIfAbsent(
                      property.id, () => TextEditingController());
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: 300,
                      child: TextFormField(
                        controller: _controllers[property.id],
                        decoration: InputDecoration(
                            labelText: property.key,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffFF8000)),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${ChallengeDetailsService.errorMessage}';
                          }
                          return null;
                        },
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Form validation passed, proceed with subscription
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String ambassadorId = prefs.getString('ambassadorId') ?? '';
                      String? souscriptionId =
                      await createSouscription(ambassadorId, challengeId);
                      if (souscriptionId != null) {
                        await submitProperties(souscriptionId);
                        saveEnteredValues();
                        setState(() {
                          showForm = false;
                        });
                      }
                    } else {
                      // Form validation failed, show error message
                      print("Please fill out all required fields.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.73, 50),
                  ),
                  child: Text('Souscrire', style: TextStyle(color: Colors.white)),
                ),
              ] else ...[
                // Display enteredValues in a card when the user is already subscribed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Color(0xffFF8000),
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vous participez déjà au ${widget.challenge.title}',
                              style: TextStyle(
                                  fontSize:15, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10,),
                          ...enteredValues.entries.map((e) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('${e.key}: ',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                Text('${e.value}',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
        
                  ),
        
                )
              ],
            ],
          ),
        ),
      ),
    );
  }






}




