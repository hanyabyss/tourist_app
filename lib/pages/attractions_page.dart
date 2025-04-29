import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tourist_app/pages/database.dart';
import 'package:tourist_app/pages/landmark.dart';
import 'package:tourist_app/pages/landmark_detail_page.dart';

class AttractionsPage extends StatefulWidget {
  final String type;
  const AttractionsPage({super.key, required this.type});

  @override
  State<AttractionsPage> createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  List<Landmark> landmarks = [];
  List<String> governorates = [];
  String selectedGovernorate = 'All';

  final Map<String, String> _typeMap = {
    'Entertainment': 'Entertainment',
    'Historical': 'Historical',
    'Cultural': 'Cultural',
    'Religion': 'Religion',
  };

  @override
  void initState() {
    super.initState();
    loadLandmarks();
  }

  Future<void> loadLandmarks() async {
    final raw = await rootBundle.loadString('assets/img/landmarks.json');
    final jsonList = json.decode(raw);

    final category = _typeMap[widget.type] ?? widget.type;

    landmarks = (jsonList as List)
        .map((e) => Landmark.fromJson(e))
        .where((l) => l.category == category)
        .toList();

    governorates = [
      'All',
      ...{for (var l in landmarks) l.location}
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedGovernorate == 'All'
        ? landmarks
        : landmarks.where((l) => l.location == selectedGovernorate).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Governorate filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: governorates.map((gov) {
                final isSelected = selectedGovernorate == gov;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedGovernorate = gov;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.white,
                    ),
                    child: Text(
                      gov,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Places section
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Places',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final lm = filtered[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LandmarkDetailPage(landmarkId: lm.landmarkId),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white10,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: lm.url,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.broken_image),
                      ),
                      title:
                          Text(lm.name, style: TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lm.location,
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<int>(
                            future: DatabaseHelper.instance
                                .getRatingCount(lm.landmarkId),
                            builder: (context, snapshot) {
                              final ratingCount = snapshot.data ?? 0;
                              return Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$ratingCount',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
