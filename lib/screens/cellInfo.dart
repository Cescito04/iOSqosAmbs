import 'dart:async';
import 'dart:convert';

import 'package:flutter_cell_info/CellResponse.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:flutter_cell_info/models/common/cell_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  CellsResponse? _cellsResponse;
  String? currentOperatorName;  // De
  // clare the operator name at the class level


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String? currentDBM;

  Future<void> initPlatformState() async {
    CellsResponse? cellsResponse;


    try {
      String? platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion!);

      cellsResponse = CellsResponse.fromJson(body);

      CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
      String info = "";
      if (currentCellInFirstChip.type == "LTE") {
        info += "eCGI = ${currentCellInFirstChip.lte?.ecgi ?? 'N/A'}\n";
        info += "CID (8b) = ${currentCellInFirstChip.lte?.cid ?? 'N/A'}\n";
        info += "eNb = ${currentCellInFirstChip.lte?.enb ?? 'N/A'}\n";
        info += "RSSI = ${currentCellInFirstChip.lte?.signalLTE?.rssi ?? 'N/A'}\n";
        info += "RSRP = ${currentCellInFirstChip.lte?.signalLTE?.rsrp ?? 'N/A'}\n";
        info += "CQI = ${currentCellInFirstChip.lte?.signalLTE?.cqi ?? 'N/A'}\n";
        info += "SNR = ${currentCellInFirstChip.lte?.signalLTE?.snr ?? 'N/A'}\n";
        info += "TA= ${currentCellInFirstChip.lte?.signalLTE?.timingAdvance}\n";
        info += "TAC = ${currentCellInFirstChip.lte?.tac ?? 'N/A'}\n";
        info += "Band = ${currentCellInFirstChip.lte?.bandLTE?.name?? 'N/A'}";
      }
      if (currentCellInFirstChip.type == "GSM") {
        info += "CID = ${currentCellInFirstChip.gsm?.cid ?? 'N/A'}\n";
        info += "LAC = ${currentCellInFirstChip.gsm?.lac ?? 'N/A'}\n";
        info += "RSSI = ${currentCellInFirstChip.gsm?.signalGSM?.rssi ?? 'N/A'}\n";
        info += "Band = ${currentCellInFirstChip.gsm?.bandGSM ?? 'N/A'}";
      }

      if (currentCellInFirstChip.type == "WCDMA") {
        info += "CID = ${currentCellInFirstChip.wcdma?.cid ?? 'N/A'}\n";
        info += "LAC = ${currentCellInFirstChip.wcdma?.lac ?? 'N/A'}\n";
        info += "RSSI = ${currentCellInFirstChip.wcdma?.signalWCDMA?.rssi ?? 'N/A'}\n";
        info += "Band = ${currentCellInFirstChip.wcdma?.bandWCDMA?.name ?? 'N/A'}";
      }
      //NR
      if (currentCellInFirstChip.type == "NR") {
        info += "PCI = ${currentCellInFirstChip.nr?.pci ?? 'N/A'}\n";
        info += "RSRP = ${currentCellInFirstChip.nr?.signalNR?.csiRsrp ?? 'N/A'}\n";
        info += "RSRQ = ${currentCellInFirstChip.nr?.signalNR?.csiRsrq ?? 'N/A'}\n";
        info += "Band = ${currentCellInFirstChip.nr?.bandNR?.name?? 'N/A'}";

      }



      currentDBM = info;
      print('LTE Info: ' + info);
    } on PlatformException {
      _cellsResponse = null;
      print('Failed to get cell info.');
    }

    if (!mounted) return;





    setState(() {
      _cellsResponse = cellsResponse;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Infos Cellule '),
        ),
        body: _cellsResponse != null
            ? ListView.builder(
          itemCount: currentDBM!.split('\n').length, // Nombre d'éléments dans la liste
          itemBuilder: (BuildContext context, int index) {
            bool isGrey = index.isOdd;

            Color backgroundColor = isGrey ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).canvasColor;

            String item = currentDBM!.split('\n')[index];

            return Column(
              children: [
                ListTile(
                  title: Text(item),
                  tileColor: backgroundColor,
                ),
              ],
            );
          },
        )
            : const Center(child: CircularProgressIndicator()),
    );
  }

  Timer? timer;

  void startTimer() {
    const oneSec = Duration(seconds: 3);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        initPlatformState();
      },
    );
  }

}