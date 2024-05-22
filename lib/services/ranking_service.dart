class RankingService{

  List<ClassementEntry> classementList = [
    ClassementEntry(nom: "Moi", score: 50, rang: 11),
    ClassementEntry(nom: "Mame Diarra", score: 100, rang: 1),
    ClassementEntry(nom: "Mor Sarr", score: 95, rang: 2),
    ClassementEntry(nom: "Babacar", score: 90, rang: 3),
    ClassementEntry(nom: "M Ciss", score: 85, rang: 4),
    ClassementEntry(nom: "Bocoum", score: 80, rang: 5),
    ClassementEntry(nom: "Bamba", score: 75, rang: 6),
    ClassementEntry(nom: "Malick", score: 70, rang: 7),
    ClassementEntry(nom: "Ndeye Fatou", score: 65, rang: 8),
    ClassementEntry(nom: "Cheikh Aldiey", score: 60, rang: 9),
    ClassementEntry(nom: "Ousseynou", score: 55, rang: 10),
    ClassementEntry(nom: "Moi", score: 50, rang: 11),
    ClassementEntry(nom: "MAS", score: 45, rang: 12),
    ClassementEntry(nom: "Jule", score: 40, rang: 13),
  ];


}

class ClassementEntry {
  final String nom;
  final int score;
  final int rang;

  ClassementEntry({required this.nom, required this.score, required this.rang});
}
