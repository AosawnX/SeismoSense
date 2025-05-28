import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  bool _vibrating = true;

  void _startHaptics(Duration splashDuration) async {
    if (await Vibration.hasVibrator() ?? false) {
      int interval = 150;
      int pause = 100;
      int elapsed = 0;

      while (_vibrating && elapsed < splashDuration.inMilliseconds) {
        Vibration.vibrate(duration: interval);
        await Future.delayed(Duration(milliseconds: interval + pause));

        // increase intensity gradually
        interval = (interval + 50).clamp(150, 600);
        elapsed += interval + pause;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) async {
        setState(() {});
        _controller.play();

        final splashDuration = _controller.value.duration;
        _startHaptics(splashDuration);

        Future.delayed(splashDuration, () {
          _vibrating = false; // stop loop
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        });

        // Wait for video to complete
        Future.delayed(_controller.value.duration, () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            _controller.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
