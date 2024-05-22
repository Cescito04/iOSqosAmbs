class SiteModel {
  final String nomSite;
  final String latitude;
  final String longitude;
  final int band;
  final List<Cell> cells;

  SiteModel({required this.nomSite, required this.latitude, required this.longitude, required this.band, required this.cells});

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    var list = json['cells'] as List;
    List<Cell> cellsList = list.map((i) => Cell.fromJson(i)).toList();
    return SiteModel(
      nomSite: json['nomSite'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      band: json['band'],
      cells: cellsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomSite': nomSite,
      'latitude': latitude,
      'longitude': longitude,
      'band': band,
      'cells': cells.map((c) => c.toJson()).toList(),
    };
  }
}

class Cell {
  final String nomCellule;

  Cell({required this.nomCellule});

  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      nomCellule: json['nomCellule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomCellule': nomCellule,
    };
  }
}
