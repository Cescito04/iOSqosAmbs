class Cell4GModel {
  String id;
  String nomSite;
  String nomCellule;
  int enodeBId;
  int localCellId;
  int cid;
  int tac;
  int physicalCellId;
  double longitude;
  double latitude;

  Cell4GModel({
    required this.id,
    required this.nomSite,
    required this.nomCellule,
    required this.enodeBId,
    required this.localCellId,
    required this.cid,
    required this.tac,
    required this.physicalCellId,
    required this.longitude,
    required this.latitude,
  });

  factory Cell4GModel.fromJson(Map<String, dynamic> json) {
    return Cell4GModel(
      id: json['id'],
      nomSite: json['nomSite'],
      nomCellule: json['nomCellule'],
      enodeBId: json['enodeBId'],
      localCellId: json['localCellId'],
      cid: json['cid'],
      tac: json['tac'],
      physicalCellId: json['physicalCellId'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nomSite'] = this.nomSite;
    data['nomCellule'] = this.nomCellule;
    data['enodeBId'] = this.enodeBId;
    data['localCellId'] = this.localCellId;
    data['cid'] = this.cid;
    data['tac'] = this.tac;
    data['physicalCellId'] = this.physicalCellId;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}
