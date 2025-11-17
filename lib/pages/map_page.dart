import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';

class MapPage extends StatefulWidget {
  final String userId;
  const MapPage({super.key, required this.userId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool isFirstCentering = true;

  LatLng myPos = LatLng(-6.2, 106.8); // default sementara
  List<Marker> markers = [];
  List<LatLng> routePoints = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initLocationAndTracking();
  }

  // 🌟 Ambil lokasi device dulu, baru mulai tracking server
  Future<void> initLocationAndTracking() async {
    await getMyLocation();
    startTracking();
  }

  // Ambil posisi GPS device
  Future<void> getMyLocation() async {
    // Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Izin lokasi ditolak");
        return;
      }
    }

    // Pastikan GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS/Location service tidak aktif");
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        myPos = LatLng(pos.latitude, pos.longitude);
      });

      // Kamera bergerak sekali setelah widget ter-build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isFirstCentering) {
          _mapController.move(myPos, 16);
          isFirstCentering = false;
        }
      });
    } catch (e) {
      print("Gagal mendapatkan posisi: $e");
    }
  }

  // Update marker dari server tiap 3 detik
  void startTracking() {
    timer = Timer.periodic(Duration(seconds: 3), (_) async {
      final data = await LocationService.getAllLocations();

      if (data.isEmpty) return;

      List<Marker> newMarkers = [];

      for (var user in data) {
        // Pastikan lat/lng diubah ke double
        double lat = double.parse(user["lat"].toString());
        double lng = double.parse(user["lng"].toString());
        LatLng pos = LatLng(lat, lng);

        // Update posisi user sendiri
        if (user["user_id"].toString() == widget.userId) {
          myPos = pos;
        }

        // Tambahkan marker
        newMarkers.add(
          Marker(
            point: pos,
            width: 40,
            height: 40,
            child: Icon(
              user["user_id"].toString() == widget.userId
                  ? Icons.person_pin_circle
                  : Icons.location_on,
              color: user["user_id"].toString() == widget.userId
                  ? Colors.blueAccent
                  : Colors.red,
              size: user["user_id"].toString() == widget.userId ? 50 : 40,
            ),
          ),
        );
      }

      setState(() {
        markers = newMarkers;
      });

      // Kamera tetap hanya bergerak sekali (sudah di getMyLocation)
    });
  }

  // Tampilkan rute dari user ke marker tertentu
  void showRoute(LatLng from, LatLng to) async {
    routePoints = await RouteService.getRoute(from, to);
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: myPos,
          zoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: markers),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (markers.length > 1) {
            showRoute(myPos, markers[1].point);
          }
        },
        child: Icon(Icons.alt_route),
      ),
    );
  }
}
