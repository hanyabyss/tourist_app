// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const _apiKey = '490d86dc7b324573a71193557241510';
  static const _baseUrl = 'http://api.weatherapi.com/v1/current.json';
  static const _defaultCities = ['London', 'Cairo', 'Alexandria'];

  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  List<WeatherData> _weatherData = [];
  List<String> _cities = _defaultCities;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList('cities') ?? _defaultCities;

    if (mounted) {
      setState(() => _cities = savedCities);
    }

    await _fetchWeatherData();
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cities', _cities);
  }

  Future<void> _fetchWeatherData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData.clear();
    });

    final results = await Future.wait(
      _cities.map((city) => _fetchCityWeather(city)),
    );

    if (!mounted) return;

    if (results.every((data) => data.condition.startsWith('Error'))) {
      setState(() {
        _weatherData = _getPlaceholderData();
        _errorMessage = 'Failed to fetch data. Showing placeholder data.';
      });
    } else {
      setState(() => _weatherData = results);
    }

    setState(() => _isLoading = false);
  }

  List<WeatherData> _getPlaceholderData() => [
        WeatherData(city: 'London', temperature: 15, condition: 'Cloudy'),
        WeatherData(city: 'Cairo', temperature: 25, condition: 'Sunny'),
        WeatherData(city: 'Alexandria', temperature: 20, condition: 'Rainy'),
      ];

  Future<WeatherData> _fetchCityWeather(String city) async {
    try {
      final url = '$_baseUrl?key=$_apiKey&q=$city';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData(
          city: data['location']['name'],
          temperature: data['current']['temp_c'].toInt(),
          condition: data['current']['condition']['text'],
          iconUrl: 'https:${data['current']['condition']['icon']}',
        );
      } else {
        return WeatherData(
          city: city,
          temperature: 0,
          condition: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return WeatherData(
        city: city,
        temperature: 0,
        condition: 'Error: $e',
      );
    }
  }

  Future<void> _searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;

    if (_cities.any((c) => c.equalsIgnoreCase(city))) {
      if (mounted) {
        setState(() => _errorMessage = 'City already in the list');
      }
      _searchController.clear();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final weather = await _fetchCityWeather(city);

    if (!mounted) return;

    if (weather.condition.startsWith('Error')) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch data for $city';
      });
      return;
    }

    setState(() {
      _cities = [..._cities, city];
      _weatherData = [..._weatherData, weather];
      _isLoading = false;
    });

    await _saveCities();
    _searchController.clear();
  }

  void _deleteCity(int index) {
    setState(() {
      _cities.removeAt(index);
      _weatherData.removeAt(index);
    });
    _saveCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E1A47),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            const StarryBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildSearchField(),
                  _buildWeatherList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: _fetchWeatherData,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for a city...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _searchCity,
          ),
        ),
        onChanged: (_) => _debouncer.run(_searchCity),
        onSubmitted: (_) => _searchCity,
      ),
    );
  }

  Widget _buildWeatherList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_weatherData.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _errorMessage ?? 'No data available',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _weatherData.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_weatherData[index].city),
          background: _buildDismissibleBackground(Alignment.centerLeft),
          secondaryBackground:
              _buildDismissibleBackground(Alignment.centerRight),
          onDismissed: (_) => _deleteCity(index),
          child: WeatherCard(weather: _weatherData[index]),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground(Alignment alignment) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: EdgeInsets.only(
        left: alignment == Alignment.centerLeft ? 20 : 0,
        right: alignment == Alignment.centerRight ? 20 : 0,
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

class WeatherData {
  final String city;
  final int temperature;
  final String condition;
  final String? iconUrl;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    this.iconUrl,
  });
}

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weather.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                weather.iconUrl != null
                    ? Image.network(
                        weather.iconUrl!,
                        width: 60,
                        height: 60,
                        errorBuilder: (_, __, ___) => const WeatherIconError(),
                      )
                    : const WeatherIconError(),
                const SizedBox(height: 8),
                Text(
                  weather.condition,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherIconError extends StatelessWidget {
  const WeatherIconError({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.error, size: 60, color: Colors.white);
  }
}

class StarryBackground extends StatelessWidget {
  const StarryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _StarryBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.5);
    final random = Random();

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}

extension StringExtensions on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
