class SubscriptionProperty {
  final String id;
  final String key;
  final String type;
  final String value;
  final String propertiesId;
  final String souscriptionId;

  SubscriptionProperty({
    required this.id,
    required this.key,
    required this.type,
    required this.value,
    required this.propertiesId,
    required this.souscriptionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'type': type,
      'value': value,
      'propertiesId': propertiesId,
      'souscriptionId': souscriptionId,
    };
  }
}
