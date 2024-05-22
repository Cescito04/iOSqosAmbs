class Cellule5GData {
  String? id;
  String? nomSite;
  String? nomCellule;
  int? cellId;
  int? tac;
  int? band;
  int? physicalCellId;
  int? logicalRootSequenceIndex;
  String? latitude;
  String? longitude;
  AdditionalProp1? additionalProp1;

  Cellule5GData({this.id, this.nomSite, this.nomCellule, this.cellId, this.tac, this.band, this.physicalCellId, this.logicalRootSequenceIndex, this.latitude, this.longitude, this.additionalProp1});

  Cellule5GData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nomSite = json['nomSite'];
    nomCellule = json['nomCellule'];
    cellId = json['cellId'];
    tac = json['tac'];
    band = json['band'];
    physicalCellId = json['physicalCellId'];
    logicalRootSequenceIndex = json['logicalRootSequenceIndex'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    additionalProp1 = json['additionalProp1'] != null ? new AdditionalProp1.fromJson(json['additionalProp1']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nomSite'] = this.nomSite;
    data['nomCellule'] = this.nomCellule;
    data['cellId'] = this.cellId;
    data['tac'] = this.tac;
    data['band'] = this.band;
    data['physicalCellId'] = this.physicalCellId;
    data['logicalRootSequenceIndex'] = this.logicalRootSequenceIndex;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.additionalProp1 != null) {
      data['additionalProp1'] = this.additionalProp1!.toJson();
    }
    return data;
  }
}


class AdditionalProp1 {
  AdditionalProp1(); // Constructor declaration with a class name.

  AdditionalProp1.fromJson(Map<String, dynamic> json) {
    // Constructor implementation
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

