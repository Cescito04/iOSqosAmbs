import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qosambassadors/screens/shimmer.dart';
import 'package:qosambassadors/screens/speedtest.dart';
import 'package:qosambassadors/services/challenge_service.dart';

import '../controller/challenge_info.dart';
import '../controller/session_utilisateur.dart';
import 'package:intl/intl.dart';
import 'package:qosambassadors/controller/historique_controller.dart';
import 'dart:async';

import 'details_challenge.dart';
import 'historic_details.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Timer? _timer;
  bool isLoading = true;
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  List<ChallengeInfo> _challenges = [];

  final HistoriqueController _controller = HistoriqueController();
  var _isLoading = false;
  final SpeedTest _speedTestController = SpeedTest();

  @override
  void initState() {
    _loadUserHistory();
    requestPermissions();
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
  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.phone,
    ].request();


  }
  Future<List<ChallengeInfo>> fetchChallenges() async {
    final response = await http.get(Uri.parse('${ChallengeDetailsService.challengesEndpoint}'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ChallengeInfo.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load challenges');
    }
  }



  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String.split(',').last);
  }




  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.location,
    ].request();
  }


  Future<void> _loadUserHistory() async {
    await _controller.fetchUserHistory();
    _controller.testResults.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(
        _challenges.length,
            (index) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade300,
          ),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Container(
            height: 280,
            child: Center(
                child: Text(
                  "Page $index",
                  style: TextStyle(color: Colors.orange),
                )),
          ),
        ));
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(

        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                color: Color(0xfffff7902),
                height: 180,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/images/qsa.png',
                      width: 170,
                      height: 160,
                    ),

                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              buildListTile("Accueil", '/home', context),
              buildListTile("Profil", '/profile', context),
              buildListTile("Parametres", '/settings', context),
              buildListTile("Challenges", '/challenge', context),
              buildListTile("RAN5G", '/cell5g', context),
              ListTile(
                title: Text("Deconnexion",
                    style: TextStyle(
                        color: Color(0xffFF8000),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(color:  Colors.orange[800]),
          title: Text("QOS AMBASSADORS",
              style: TextStyle(color: Color(0xffFF8000), fontSize: 20)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: Icon(Icons.person, color:  Color(0xffFF8000)),
            ),
          ],
          centerTitle: true,
        ),

        body: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child:isLoading?ShimmerScreen():ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemCount: _challenges.length,
                itemBuilder: (context, index) {
                  final challenge = _challenges[index];
                  Uint8List imageBytes = dataFromBase64String(challenge.imagePath);

                  return Container(

                    width: 350,
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
                  );
                },
              ),

            ),
            SizedBox(height: 10,),
            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.orange,
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,


                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 35),
                              Text(
                                "Tester votre débit",
                                style: TextStyle(
                                    color: Color(0xffFF8000),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Column(
                            children: [
                              buildCircularButton("Go", () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SpeedTest())).then(
                                        (_) => Future.delayed(Duration.zero, () {
                                      _loadUserHistory();

                                    }));
                              }, context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historiques",
                    style: TextStyle(
                        color: Color(0xffFF8000),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/historique');
                    },
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Voir plus",
                          style: TextStyle(
                              color: Color(0xffFF8000),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xffFF8000),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Text(
                  'Type',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xffFF8000)),
                ),
                Text(
                  'Ping',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xffFF8000)),
                ),
                Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                  ],

                ),
                Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                  ],
                ),
                Text(
                  'Techno',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xffFF8000)),
                ),
              ],
            ),
            Expanded(
              child:  _isLoading
                  ? ListView.builder(
                itemCount: _controller.testResults.length < 10 ? _controller.testResults.length : 10,
                itemBuilder: (context, index) {
                  var result = _controller.testResults[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '  ${result['date'] != null ? _formatDate(result['date']) : 'N/A'}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HistoryDetails(index: index,)),
                                );
                              },
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(80), // Fix the width for the "type" column
                                  1: FlexColumnWidth(),
                                  2: FlexColumnWidth(),
                                  3: FlexColumnWidth(),
                                  4: FlexColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text(
                                        '${result['type'] ?? 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${result['ping'] ?? 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${result['dlmoy'] != null ? (result['dlmoy'] as num).toInt() : 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${result['ulmoy'] != null ? (result['ulmoy'] as num).toInt() : 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${result['techno'] ?? 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : ShimmerList(),
            ),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile(String title, String route, BuildContext context) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
              color:Color(0xffFF8000),
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget buildCircularButton(
      String label, VoidCallback onPressed, BuildContext context) {
    return Hero(
      tag: 'heroTag_$label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SpeedTest();
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xffFF8000),
                  Color(0xffFF8000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange,
                  spreadRadius: 0,
                  blurRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],

            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await UserSession.setLoggedOut();

              Navigator.pushNamedAndRemoveUntil(
                  context, '/authentification', (route) => false);
            },
            child: Text("Déconnexion"),
          ),
        ],
      );
    },
  );
}

String _formatDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
  return formattedDate;
}



