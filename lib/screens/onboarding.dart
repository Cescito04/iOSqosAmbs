import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

import '../services/onboarding_service.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> _pageContent = [];

  @override
  void initState() {
    super.initState();
    _fetchOnBoardingPages();
  }

  Future<void> _fetchOnBoardingPages() async {
    try {
      List<Map<String, dynamic>> pages = await OnBoardingService.fetchOnBoardingPages();
      setState(() {
        _pageContent = pages;
      });
    } catch (e) {
      // Handle error
      print('Error fetching onboarding pages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page.toInt();
                  });
                },
                children: _pageContent.map((page) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page['mainTitle'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Image.asset(
                        page['image'],
                        width: 500,
                        height: 300,
                      ),
                      SizedBox(height: 20),
                      Text(
                        page['title'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                    ],
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                DotsIndicator(
                  dotsCount: _pageContent.length,
                  position: _currentPage,
                  decorator: DotsDecorator(
                    color: Colors.orange.withOpacity(0.2),
                    activeColor: Colors.orange,
                    size: const Size.square(12.0),
                    spacing: const EdgeInsets.all(3.0),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage < _pageContent.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    } else {
                      Navigator.pushNamed(context, '/authentification');
                    }
                  },
                  child: _currentPage < _pageContent.length - 1
                      ? Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: Colors.orange,
                  )
                      : Text(
                    _pageContent[_currentPage.toInt()]['buttonText'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(
                      horizontal: _currentPage < _pageContent.length - 1 ? 20 : 50,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

