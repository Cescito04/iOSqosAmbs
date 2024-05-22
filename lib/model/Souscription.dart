class Souscription {
  final String id;
  final String ambassadorId;
  final String challengeId;

  Souscription({
    required this.id,
    required this.ambassadorId,
    required this.challengeId,
  });

  factory Souscription.fromJson(Map<String, dynamic> json) {
    return Souscription(
      id: json['id'],
      ambassadorId: json['ambassadorId'],
      challengeId: json['challengeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambassadorId': ambassadorId,
      'challengeId': challengeId,
    };
  }
}
