class CellHistory {
  String? id;
  String? type;
  double? ping;
  double? download;
  String? date;
  double? upload;
  double? latitude;
  double? longitude;
  double? ulmin;
  double? dlmin;
  bool? success;
  String? ambassadorId;
  String? cellule;
  double? pCI;
  double? rSRP;
  double? rSRQ;
  double? band;
  double? aRFCN;
  double? dLFrequence;
  double? bandNumber;
  double? bandName;
  double? channelNumber;
  double? tAC;
  double? nCI;
  double? dBM;
  double? cSIRSRQ;
  double? cSISINR;
  double? sSRSRP;
  double? sSRSRQ;
  double? sSSINR;
  double? sSRSRPASU;
  double? eCGI;
  double? cID8b;
  double? eNb;
  double? rSSI;
  double? cQI;
  double? sNR;
  double? tA;
  double? bandwidth;
  double? cID;
  double? lAC;
  double? pSC;
  double? dARFCN;
  double? rNC;
  double? cGI;
  double? cI;
  double? rSSIASU;
  double? dbm;
  double? eCIO;
  double? rSCP;
  double? rSCPASU;
  AdditionalProp1? additionalProp1;

  CellHistory({this.id, this.type, this.ping, this.download, this.date, this.upload, this.latitude, this.longitude, this.ulmin, this.dlmin, this.success, this.ambassadorId, this.cellule, this.pCI, this.rSRP, this.rSRQ, this.band, this.aRFCN, this.dLFrequence, this.bandNumber, this.bandName, this.channelNumber, this.tAC, this.nCI, this.dBM, this.cSIRSRQ, this.cSISINR, this.sSRSRP, this.sSRSRQ, this.sSSINR, this.sSRSRPASU, this.eCGI, this.cID8b, this.eNb, this.rSSI, this.cQI, this.sNR, this.tA, this.bandwidth, this.cID, this.lAC, this.pSC, this.dARFCN, this.rNC, this.cGI, this.cI, this.rSSIASU, this.dbm, this.eCIO, this.rSCP, this.rSCPASU, this.additionalProp1});

  CellHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    ping = json['ping'];
    download = json['download'];
    date = json['date'];
    upload = json['upload'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    ulmin = json['ulmin'];
    dlmin = json['dlmin'];
    success = json['success'];
    ambassadorId = json['ambassadorId'];
    cellule = json['cellule'];
    pCI = json['PCI'];
    rSRP = json['RSRP'];
    rSRQ = json['RSRQ'];
    band = json['Band'];
    aRFCN = json['ARFCN'];
    dLFrequence = json['DLFrequence'];
    bandNumber = json['BandNumber'];
    bandName = json['BandName'];
    channelNumber = json['ChannelNumber'];
    tAC = json['TAC'];
    nCI = json['NCI'];
    dBM = json['DBM'];
    cSIRSRQ = json['CSIRSRQ'];
    cSISINR = json['CSISINR'];
    sSRSRP = json['SSRSRP'];
    sSRSRQ = json['SSRSRQ'];
    sSSINR = json['SSSINR'];
    sSRSRPASU = json['SSRSRPASU'];
    eCGI = json['eCGI'];
    cID8b = json['CID_8b'];
    eNb = json['eNb'];
    rSSI = json['RSSI'];
    cQI = json['CQI'];
    sNR = json['SNR'];
    tA = json['TA'];
    bandwidth = json['Bandwidth'];
    cID = json['CID'];
    lAC = json['LAC'];
    pSC = json['PSC'];
    dARFCN = json['DARFCN'];
    rNC = json['RNC'];
    cGI = json['CGI'];
    cI = json['CI'];
    rSSIASU = json['RSSIASU'];
    dbm = json['dbm'];
    eCIO = json['ECIO'];
    rSCP = json['RSCP'];
    rSCPASU = json['RSCPASU'];
    additionalProp1 = json['additionalProp1'] != null ? new AdditionalProp1.fromJson(json['additionalProp1']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['ping'] = this.ping;
    data['download'] = this.download;
    data['date'] = this.date;
    data['upload'] = this.upload;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['ulmin'] = this.ulmin;
    data['dlmin'] = this.dlmin;
    data['success'] = this.success;
    data['ambassadorId'] = this.ambassadorId;
    data['cellule'] = this.cellule;
    data['PCI'] = this.pCI;
    data['RSRP'] = this.rSRP;
    data['RSRQ'] = this.rSRQ;
    data['Band'] = this.band;
    data['ARFCN'] = this.aRFCN;
    data['DLFrequence'] = this.dLFrequence;
    data['BandNumber'] = this.bandNumber;
    data['BandName'] = this.bandName;
    data['ChannelNumber'] = this.channelNumber;
    data['TAC'] = this.tAC;
    data['NCI'] = this.nCI;
    data['DBM'] = this.dBM;
    data['CSIRSRQ'] = this.cSIRSRQ;
    data['CSISINR'] = this.cSISINR;
    data['SSRSRP'] = this.sSRSRP;
    data['SSRSRQ'] = this.sSRSRQ;
    data['SSSINR'] = this.sSSINR;
    data['SSRSRPASU'] = this.sSRSRPASU;
    data['eCGI'] = this.eCGI;
    data['CID_8b'] = this.cID8b;
    data['eNb'] = this.eNb;
    data['RSSI'] = this.rSSI;
    data['CQI'] = this.cQI;
    data['SNR'] = this.sNR;
    data['TA'] = this.tA;
    data['Bandwidth'] = this.bandwidth;
    data['CID'] = this.cID;
    data['LAC'] = this.lAC;
    data['PSC'] = this.pSC;
    data['DARFCN'] = this.dARFCN;
    data['RNC'] = this.rNC;
    data['CGI'] = this.cGI;
    data['CI'] = this.cI;
    data['RSSIASU'] = this.rSSIASU;
    data['dbm'] = this.dbm;
    data['ECIO'] = this.eCIO;
    data['RSCP'] = this.rSCP;
    data['RSCPASU'] = this.rSCPASU;
    if (this.additionalProp1 != null) {
      data['additionalProp1'] = this.additionalProp1!.toJson();
    }
    return data;
  }
}

class AdditionalProp1 {
  AdditionalProp1();

  AdditionalProp1.fromJson(Map<String, dynamic> json) {
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}
