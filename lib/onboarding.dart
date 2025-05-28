import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<SlideActionState> _slideKey = GlobalKey();
  int _currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onb1.png",
      "title": "Welcome to SeismoSense",
      "desc": "Get prepared for earthquake alerts and risk forecasts.",
    },
    {
      "image": "assets/images/onb2.png",
      "title": "Stay Informed",
      "desc": "Simulate earthquake impact anywhere on the map.",
    },
    {
      "image": "assets/images/onb3.png",
      "title": "Be Prepared",
      "desc": "Get AI-powered insights for safety.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Image.asset('assets/images/Logo.png', height: 32),
          const SizedBox(height: 20),

          // PageView content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final page = pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page["image"]!, height: 250),
                      const SizedBox(height: 30),
                      Text(
                        page["title"]!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page["desc"]!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                width: _currentIndex == index ? 12 : 8,
                height: _currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == index
                          ? Colors.red
                          : const Color(0xFFFFE5E5),
                ),
              ),
            ),
          ),

          // Slide to Start
          if (_currentIndex == pages.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SlideAction(
                key: _slideKey,
                borderRadius: 16,
                elevation: 4,
                outerColor: Colors.white,
                innerColor: Colors.red,
                sliderButtonIcon: TweenAnimationBuilder(
                  tween: Tween(begin: 1.0, end: 1.2),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.shield, color: Colors.white),
                    );
                  },
                  onEnd: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() {});
                    });
                  },
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Slide to get started",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ),
                onSubmit: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/siglogpage');
                },
              ),
            )
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}
