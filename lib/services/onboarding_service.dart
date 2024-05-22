
class OnBoardingService {
  static Future<List<Map<String, dynamic>>> fetchOnBoardingPages() async {
    final List<Map<String, dynamic>> pages = [
      {
        'mainTitle': 'Communauté QOS Ambassadors.',
        'image': "assets/images/ob4.png",
        'title': "Bienvenue dans la communauté des ambassadeurs de la QOS réseau.",
        'buttonText': "Passer",
      },
      {
        'mainTitle': 'Qualité réseau.',
        'image': "assets/images/ob1.png",
        'title': "Tester la qualité du réseau pour améliorer l'expérience de nos clients.",
        'buttonText': "Passer",
      },
      {
        'mainTitle': 'Challenges',
        'image': "assets/images/ob3.png",
        'title': "Participer à des challenges et gagner des cadeaux en retour",
        'buttonText': "Passer",
      },
      {
        'mainTitle': 'Remontées des incidents',
        'image': "assets/images/ob2.png",
        'title': "Partager les dysfonctionnements du réseau que vous vivez et aider nous à les corriger. ",
        'buttonText': "Commencer",
      },
    ];

    return pages;
  }
}
