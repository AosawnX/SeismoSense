import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/siglogpage');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "guest@seismosense.com";
    final displayName = user?.displayName;
    final photoURL = user?.photoURL;

    Widget avatar;
    if (photoURL != null) {
      avatar = CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(photoURL),
      );
    } else {
      avatar = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.redAccent,
        child: Text(
          email[0].toUpperCase(),
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFE5E5),
        child: Column(
          children: [
            const SizedBox(height: 50),
            ListTile(
              leading: avatar,
              title: Text(
                displayName ?? email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email, style: const TextStyle(fontSize: 12)),
            ),
            const Divider(thickness: 1.2),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.black87),
              title: const Text(
                "About",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "SeismoSense",
                  applicationVersion: "v1.0.0",
                  children: [
                    const Text(
                      "AI-powered earthquake alert and prediction app.",
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black87),
              title: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.black87),
              title: const Text(
                "What to do in an earthquake",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/tips');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.black87),
              title: const Text(
                "Developers",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/developers');
              },
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                '© SeismoSense 2025',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
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
                    Builder(
                      builder:
                          (context) => IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                    ),
                    Image.asset('assets/images/logoIcon.png', height: 36),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => _logout(context),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),

              // Black info bar
              Container(
                color: Colors.black,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
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
      body: MapContent(),
    );
  }
}

class MapContent extends StatefulWidget {
  const MapContent({super.key});

  @override
  State<MapContent> createState() => _MapContentState();
}

class _MapContentState extends State<MapContent> {
  GoogleMapController? _controller;
  LatLng _initialPosition = const LatLng(33.6844, 73.0479);
  Set<Marker> _markers = {};
  LatLng? _lastPlacedLatLng;
  bool _isLoading = false;

  final _magnitudeController = TextEditingController();
  final _depthController = TextEditingController();
  List<Map<String, dynamic>> predictionHistory = [];

  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
    _loadMarkersFromFirestore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Long press on map to place a marker')),
      );
    });
  }

  Future<void> _getLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _initialPosition = LatLng(pos.latitude, pos.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _initialPosition,
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required')),
      );
    }
  }

  Future<void> _loadMarkersFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('markers').get();
    final loadedMarkers =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(data['lat'], data['lng']),
            infoWindow: const InfoWindow(title: 'Saved Marker'),
          );
        }).toSet();

    setState(() {
      _markers.addAll(loadedMarkers);
    });
  }

  Future<void> _saveMarkerToFirestore(LatLng pos) async {
    await FirebaseFirestore.instance.collection('markers').add({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _onLongPress(LatLng pos) {
    final newMarker = Marker(
      markerId: const MarkerId('single_marker'),
      position: pos,
      infoWindow: const InfoWindow(title: 'Selected Location'),
    );

    setState(() {
      _markers.clear();
      _markers.add(newMarker);
      _lastPlacedLatLng = pos;
    });

    _saveMarkerToFirestore(pos);
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marker placed at ${pos.latitude}, ${pos.longitude}'),
      ),
    );
  }

  Future<void> _predictCasualties() async {
    if (_lastPlacedLatLng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Place a marker first")));
      return;
    }

    double? mag = double.tryParse(_magnitudeController.text);
    double? depth = double.tryParse(_depthController.text);

    if (mag == null || depth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid magnitude and depth")),
      );
      return;
    }

    setState(() => _isLoading = true); // start loading

    final response = await ApiService.sendPredictionRequest(
      magnitude: mag,
      depth: depth,
      latitude: _lastPlacedLatLng!.latitude,
      longitude: _lastPlacedLatLng!.longitude,
    );

    setState(() => _isLoading = false); // stop loading

    if (response != null) {
      setState(() {
        predictionHistory.insert(0, {
          "magnitude": mag,
          "depth": depth,
          "latitude": _lastPlacedLatLng!.latitude,
          "longitude": _lastPlacedLatLng!.longitude,
          "casualties": response["casualties"],
        });
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Prediction failed")));
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal
              ? MapType.satellite
              : _mapType == MapType.satellite
              ? MapType.terrain
              : MapType.normal;
    });
  }

  Color _getCardColor(int casualties) {
    if (casualties < 10) return Colors.green.shade100;
    if (casualties > 100) return Colors.red.shade100;
    if (casualties > 50) return Colors.orange.shade100;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(
              0xFFFFF3E0,
            ), // Soft peach background (not white or purple)
            elevation: 4,
            shadowColor: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary:
                            Colors.redAccent, // Color of underline/focus border
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _magnitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Magnitude",
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _depthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Depth (km)",
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                            strokeWidth: 3.5,
                          ),
                        ),
                      )
                      : ElevatedButton.icon(
                        onPressed: _predictCasualties,
                        icon: const Icon(Icons.analytics, color: Colors.white),
                        label: const Text(
                          "Predict Casualties",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Choose Location for Simulation",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 15,
                ),
                mapType: _mapType,
                onMapCreated: (controller) => _controller = controller,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                markers: _markers,
                onLongPress: _onLongPress,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_lastPlacedLatLng != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(
                        0xFFFFF3E0,
                      ), // soft peach (same as input card)
                      elevation: 3,
                      shadowColor: Colors.orange.shade100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Text(
                          'Lat: ${_lastPlacedLatLng!.latitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xFFFFF3E0),
                      elevation: 3,
                      shadowColor: Colors.orange.shade100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Text(
                          'Lng: ${_lastPlacedLatLng!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
          const Text(
            "Prediction History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: predictionHistory.length,
            itemBuilder: (context, index) {
              final item = predictionHistory[index];
              final casualties = item["casualties"] as int? ?? 0;
              return Card(
                color: _getCardColor(casualties),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber,
                    color: Colors.red.shade400,
                  ),
                  title: Text("Predicted Casualties: $casualties"),
                  subtitle: Text(
                    "Mag: ${item["magnitude"]}, Depth: ${item["depth"]}km\n"
                    "Lat: ${item["latitude"].toStringAsFixed(4)}, "
                    "Lon: ${item["longitude"].toStringAsFixed(4)}",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
