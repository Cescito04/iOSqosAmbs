import 'package:flutter/material.dart';
import 'package:qosambassadors/controller/historique_controller.dart';

import 'package:intl/intl.dart';
import 'package:qosambassadors/screens/shimmer.dart';

import 'historic_details.dart';

class Historique extends StatefulWidget {
  const Historique({super.key});
  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> with WidgetsBindingObserver {
  final HistoriqueController _controller = HistoriqueController();
  final ScrollController _scrollController = ScrollController();
  var _isLoading = false;
  @override
  void initState() {
    _loadUserHistory();
    _scrollToTop();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  void _scrollToTop() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadUserHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique mesures'),
        centerTitle: false,
      ),
      body:Expanded(
        child: _isLoading
            ? Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Type',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Text(
                    'Ping',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                  Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                  Text(
                    'Techno',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _controller.testResults.length,
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
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.grey, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HistoryDetails(
                                          index: index,
                                        )),
                                  );
                                },
                                child: Table(
                                  columnWidths: const {
                                    0: FixedColumnWidth(80),
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
                ),
              ),
            ),
          ],
        )
            : ShimmerList(),
      )
      );

  }
}

String _formatDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
  return formattedDate;
}
