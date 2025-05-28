import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DevelopersPage extends StatelessWidget {
  const DevelopersPage({super.key});

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  Widget buildCard({
    required String name,
    required String role,
    required String description,
    required String imageUrl,
    required String linkedin,
    required String whatsapp,
    String? github,
  }) {
    return Card(
      color: const Color(0xFFFFE5E5),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.whatsapp),
                        onPressed: () => _launchURL(whatsapp),
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.linkedin),
                        onPressed: () => _launchURL(linkedin),
                      ),
                      if (github != null)
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.github),
                          onPressed: () => _launchURL(github),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meet the Developers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: [
          buildCard(
            name: "Syed Abdullah Shah",
            role: "AI Engineer & Frontend Developer",
            description:
                "Specializes in AI model integration and building intuitive user experiences. Passionate about cybersecurity and app development.",
            imageUrl: 'assets/images/dev1.jpg', // Replace with real image
            whatsapp: "https://wa.me/923265656230",
            linkedin: "https://www.linkedin.com/in/shahabdullahbuk/",
            github: "https://github.com/AosawnX",
          ),
          buildCard(
            name: "Ahsan Rasheed",
            role: "API Developer",
            description:
                "Focused on backend services and real-time data handling for scalable, efficient alert systems.",
            imageUrl: 'assets/images/dev2.jpg', // Replace with real image
            whatsapp: "https://wa.me/923365186355",
            linkedin: "https://www.linkedin.com/in/ahsan-rasheed-32351126a/",
            github: "https://github.com/AosawnX", // To be filled later
          ),
        ],
      ),
    );
  }
}
