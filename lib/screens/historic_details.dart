import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qosambassadors/model/cell_history.dart';
import 'package:qosambassadors/services/historique_service.dart';
import '../controller/historique_controller.dart';
import '../services/image_service.dart';
import 'package:http/http.dart' as http;

class HistoryDetails extends StatefulWidget {
  final int index;
  const HistoryDetails({Key? key, required this.index}) : super(key: key);

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails>
    with WidgetsBindingObserver {
  final HistoriqueController _controller = HistoriqueController();
  final ScrollController _scrollController = ScrollController();
  late Future<CellHistory> futureData;

  List<dynamic> data = [];

  Future<void> fetchDataCell() async {
    try {
      final response = await http
          .get(Uri.parse('${HistoriqueService.dataHistoriesEndpoint}'));
      log("API");
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserHistory(widget.index);
    WidgetsBinding.instance!.addObserver(this);
    fetchDataCell();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserHistory(int index) async {
    await _controller.fetchUserHistory();
    _controller.testResults.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    setState(() {
      _controller.setTestResults(index < _controller.testResults.length
          ? [_controller.testResults[index]]
          : []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails mesure'),
        centerTitle: false,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var result = _controller.testResults[index];
                return Column(
                  children: [
                    Container(
                      height: 60,
                      margin: const EdgeInsets.all(10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Type : ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 19)),
                            const SizedBox(width: 10),
                            Text('${result['type']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey)),
                            const Icon(Icons.date_range_outlined),
                            Text(
                                '  ${result['date'] != null ? _formatDate(result['date']) : 'N/A'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),

                    result['type'] == "auto     "? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSpeedCard(
                              'assets/images/down_arrow.png',
                              '${result['download']}',
                              '${result['dlmin']}',
                              'DLmin',
                              '${result['type']}',
                            '',
                          ),
                          const SizedBox(width: 10),
                          _buildSpeedCard(
                              'assets/images/up_arrow.png',
                              '${result['upload']}',
                              '${result['ulmin']}',
                              'ULmin',
                              '${result['type']}',
                            '',
                          ),
                        ],
                      ):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSpeedCard(
                              'assets/images/down_arrow.png',
                              '${(result['dlmoy']).toInt()}',
                              '${result['dlmin']}',
                              'DLmin',
                              '${result['type']}',
                              '${result['dlmax']}'),
                          const SizedBox(width: 10),
                          _buildSpeedCard(
                              'assets/images/up_arrow.png',
                              '${(result['ulmoy']).toInt()}',
                              '${result['ulmin']}',
                              'ULmin',
                              '${result['type']}',
                              '${result['ulmax']}'),
                        ],
                      ),




                    Container(
                      height: 100,
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Ping",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19)),
                                const SizedBox(width: 10),
                                const Text("ms",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Image(
                                  image: ImageService.getImageAsset(
                                      'transfer.png'), // Utilisation du service d'image
                                  //width: 60,
                                  color: Colors.yellow.shade600,
                                  height: 40,
                                ),
                                const SizedBox(width: 10),
                                Text('${result['ping']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19)),
                                const SizedBox(width: 20),
                                const Text("Techno : ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19)),
                                Text('${result['techno']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              childCount: _controller.testResults.length,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var result = _controller.testResults[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (result['type'] == "manuel")
                          if (result['techno'] == "5G")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: 2,
                              ),
                              itemCount: _buildCardList5G(result).length,
                              itemBuilder: (context, index) {
                                return _buildCardList5G(result)[index];
                              },
                            ),
                        if (result['type'] == "manuel")
                          if (result['techno'] == "4G")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 5,
                                childAspectRatio: 2,
                              ),
                              itemCount: _buildCardList4G(result).length,
                              itemBuilder: (context, index) {
                                return _buildCardList4G(result)[index];
                              },
                            ),
                        if (result['type'] == "manuel")
                          if (result['techno'] == "2G")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 5,
                                childAspectRatio: 2,
                              ),
                              itemCount: _buildCardList2G(result).length,
                              itemBuilder: (context, index) {
                                return _buildCardList2G(result)[index];
                              },
                            ),
                        if (result['type'] == "manuel")
                          if (result['techno'] == "3G")
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 5,
                                childAspectRatio: 2,
                              ),
                              itemCount: _buildCardList3G(result).length,
                              itemBuilder: (context, index) {
                                return _buildCardList3G(result)[index];
                              },
                            ),
                      ],
                    )
                  ],
                );
              },
              childCount: _controller.testResults.length,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var result = _controller.testResults[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [],
                    ),
                    IconButton(
                      onPressed: () async {
                        double latitude = result['latitude'];
                        double longitude = result['longitude'];
                        try {
                          _controller.openMap(latitude, longitude);
                        } catch (e) {
                          print("Error launching Google Maps: $e");
                        }
                      },
                      icon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Card(
                                elevation: 0,
                                child: Image(
                                  image: ImageService.getImageAsset('maps.png'),
                                  fit: BoxFit.cover,
                                ))),
                      ),
                      tooltip: 'Géolocalisation',
                    ),
                  ],
                );
              },
              childCount: _controller.testResults.length,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
  }

  Widget _buildSpeedCard(String iconPath, String speedMoy, String measure,
      String label, String type,String speedMax) {
    return Container(
      height: 180,
      width: 170,
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (type == "auto     ")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$label',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                  SizedBox(
                    width: 10,
                  ),
                  Text('$measure',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Mpbs',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(iconPath, height: 20),
                const SizedBox(width: 10),
                const Text("Mbps",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 16)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Moy : "),
                Text('$speedMoy ', style: const TextStyle(fontSize: 27)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Max : "),
                Text('$speedMax ', style: const TextStyle(fontSize: 27)),
              ],
            ),

          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardList5G(Map<String, dynamic> result) {
    List<String> keys = [
      "pci",
      "rsrp",
      "rsrq",
      "band",
      "arfcn",
      "dlFrequence",
      "bandNumber",
      "bandName",
      "channelNumber",
      "tac",
      "nci",
      "dbm",
      "csirsrq",
      "csirsrpasu",
      "csisinr",
      "ssrsrp",
      "ssrsrq",
      "sssinr",
      "ssrsrpasu",
    ];



    return keys.map((key) {
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical alignment to center
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min, // Use minimal space needed by column
              crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center horizontally
              children: [
                Text("$key", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text((result[key] ?? 'N/A').toString(), style: TextStyle(fontSize: 10)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  List<Widget> _buildCardList4G(Map<String, dynamic> result) {
    List<String> keys = [
      'ecgi',
      'cid',
      'eNb',
      'rssi',
      'cqi',
      'snr',
      'ta',
      'tac',
      'band',
      'bandWidth',
      'pci',
      'arfcn',
      'channelNumber',
      'bandNumber',
      'bandName',
      'rsrp',
      'rsrq',
    ];

    return keys.map((key) {
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical alignment to center
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min, // Use minimal space needed by column
              crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center horizontally
              children: [
                Text("$key", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text((result[key] ?? 'N/A').toString(), style: TextStyle(fontSize: 10)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildCardList3G(Map<String, dynamic> result) {
    List<String> keys = [
      "cid",
      "lac",
      "rssi",
      "band",
      "psc",
      "darfcn",
      "bandNumber",
      "bandName",
      "channelNumber",
      "rnc",
      "cgi",
      "ci",
      "rssi",
      "rssiAsu",
      "dbm",
      "ecio",
      "rscp",
      "rscpAsu",
    ];


    return keys.map((key) {
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical alignment to center
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min, // Use minimal space needed by column
              crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center horizontally
              children: [
                Text("$key", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text((result[key] ?? 'N/A').toString(), style: TextStyle(fontSize: 10)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildCardList2G(Map<String, dynamic> result) {
    List<String> keys = [
      "cid",
      "lac",
      "rssi",
      "band",
      "arfcn",
      "rssi ",
    ];

    return keys.map((key) {
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical alignment to center
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
            SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min, // Use minimal space needed by column
              crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center horizontally
              children: [
                Text("$key", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text((result[key] ?? 'N/A').toString(), style: TextStyle(fontSize: 10)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.orange,
                margin: EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

}
