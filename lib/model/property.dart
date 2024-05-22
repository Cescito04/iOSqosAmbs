class Property {
  String id;
  String key;
  String type;
  String? challengeId; // Making it optional since not all properties have it

  Property({
    required this.id,
    required this.key,
    required this.type,
    this.challengeId, // Optional
  });

  // Factory constructor to create a Property instance from a JSON map
  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'],
    key: json['key'],
    type: json['type'],
    challengeId: json['challengeId'], // This will be null if 'challengeId' is not in the JSON
  );

  // Method to convert a Property instance into a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    // Only add 'challengeId' to JSON if it's not null
    if (this.challengeId != null) {
      data['challengeId'] = this.challengeId;
    }
    return data;
  }
}
