import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Landmark {
  final String name;
  final LatLng position;

  const Landmark({required this.name, required this.position});
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialZoom = 15.0;
  static const _tileLayerUrl =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _subdomains = ['a', 'b', 'c'];

  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  final List<Landmark> _landmarks = const [
    Landmark(name: "الأهرامات", position: LatLng(29.9792, 31.1342)),
    Landmark(name: "قلعة صلاح الدين", position: LatLng(30.0299, 31.2617)),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled && !await _location.requestService()) return;

      final permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied &&
          await _location.requestPermission() != PermissionStatus.granted) {
        return;
      }

      final locationData = await _location.getLocation();
      _updatePosition(LatLng(locationData.latitude!, locationData.longitude!));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updatePosition(LatLng newPosition) {
    if (!mounted) return;

    setState(() {
      _currentPosition = newPosition;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.move(newPosition, _initialZoom);
      } catch (e) {
        debugPrint("MapController not ready: $e");
      }
    });
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1");

      final response = await http.get(url, headers: {
        'User-Agent': 'flutter_map_app',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          _updatePosition(LatLng(lat, lon));
          return;
        }
      }

      setState(() => _errorMessage = 'Location not found');
    } catch (e) {
      setState(() => _errorMessage = 'Search failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المواقع السياحية'),
        centerTitle: true,
      ),
      body: _buildMapContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeLocation,
        tooltip: 'موقعي الحالي',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_currentPosition == null) {
      return const Center(child: Text('Unable to determine location'));
    }

    return Stack(
      children: [
        _buildMap(),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: _initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileLayerUrl,
          subdomains: _subdomains,
          userAgentPackageName: 'com.example.flutter_map_app',
        ),
        MarkerLayer(
          markers: [
            _buildCurrentLocationMarker(),
            ..._buildLandmarkMarkers(),
          ],
        ),
      ],
    );
  }

  Marker _buildCurrentLocationMarker() {
    return Marker(
      point: _currentPosition!,
      width: 40,
      height: 40,
      child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
    );
  }

  List<Marker> _buildLandmarkMarkers() {
    return _landmarks.map((landmark) {
      return Marker(
        point: landmark.position,
        width: 35,
        height: 35,
        child: Tooltip(
          message: landmark.name,
          child: const Icon(Icons.location_on, color: Colors.red, size: 35),
        ),
      );
    }).toList();
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن مكان...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: _searchPlace,
        ),
      ),
    );
  }
}
