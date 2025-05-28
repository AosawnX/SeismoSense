import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  final tips = const [
    {
      'text':
          'Drop, Cover, and Hold On. Get under a sturdy table to protect yourself.',
      'icon': 'assets/images/table.png',
    },
    {
      'text': 'Stay away from windows, shelves, and tall furniture.',
      'icon': 'assets/images/window.png',
    },
    {
      'text':
          'If you are outside, move to an open area away from buildings and power lines.',
      'icon': 'assets/images/wires.png',
    },
    {
      'text':
          'If in a vehicle, stop safely and stay inside until the shaking stops.',
      'icon': 'assets/images/car.png',
    },
    {
      'text':
          'After the quake, check for injuries and hazards. Expect aftershocks.',
      'icon': 'assets/images/injury.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top gray bar
              Container(
                color: Colors.grey[300],
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Image.asset('assets/images/logoIcon.png', height: 36),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
              // Black info bar
              Container(
                color: Colors.black,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Center(
                        child: Text(
                          'The AI model can make mistakes. Only use it as an estimate.',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            color: const Color(0xFFFFE5E5), // light red background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      tip['icon']!,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip['text']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
