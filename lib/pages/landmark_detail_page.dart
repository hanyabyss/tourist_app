import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourist_app/pages/database.dart';
import 'package:tourist_app/pages/landmark.dart';

class LandmarkDetailPage extends StatefulWidget {
  final int landmarkId;
  const LandmarkDetailPage({super.key, required this.landmarkId});

  @override
  State<LandmarkDetailPage> createState() => _LandmarkDetailPageState();
}

class _LandmarkDetailPageState extends State<LandmarkDetailPage> {
  Map<String, dynamic>? landmarkData;
  List<String> imageUrls = [];
  List<Map<String, dynamic>> reviews = [];
  List<Landmark> suggestions = [];
  int selectedStars = 0;
  final TextEditingController _commentController = TextEditingController();
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final landmarkJson =
        await rootBundle.loadString('assets/img/landmarks.json');
    final mergedJson = await rootBundle.loadString('assets/img/merged.json');

    final List<dynamic> landmarkList = json.decode(landmarkJson);
    final List<dynamic> mergedList = json.decode(mergedJson);

    landmarkData = landmarkList.firstWhere(
      (item) => item['Landmark_Id'] == widget.landmarkId,
      orElse: () => null,
    );

    imageUrls = mergedList
        .where((item) => item['landmark_id'] == widget.landmarkId)
        .map<String>((item) => item['url'] as String)
        .toList();

    await loadCurrentUser();
    await loadReviews();
    await loadSuggestions(landmarkList);
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user != null) {
        currentUserName = user['name'];
      }
    }
  }

  Future<void> loadReviews() async {
    reviews =
        await DatabaseHelper.instance.getRatingsForLandmark(widget.landmarkId);
    setState(() {});
  }

  Future<void> loadSuggestions(List<dynamic> landmarkList) async {
    final topRated = await DatabaseHelper.instance.getTopRatedLandmarks();

    suggestions = topRated
        .where((e) => e['Landmark_Id'] != widget.landmarkId)
        .take(5)
        .map((e) => Landmark.fromJson(e))
        .toList();

    setState(() {});
  }

  Future<void> submitReview() async {
    final comment = _commentController.text.trim();
    if (selectedStars == 0 || comment.isEmpty || currentUserName == null)
      return;

    await DatabaseHelper.instance.insertRating(
      widget.landmarkId,
      selectedStars,
      comment,
      currentUserName!,
    );

    _commentController.clear();
    selectedStars = 0;
    await loadReviews();
    await loadSuggestions([]);
  }

  Future<void> editReview(int reviewId, String oldComment, int oldStars) async {
    final TextEditingController editController =
        TextEditingController(text: oldComment);
    int newStars = oldStars;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < newStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    ),
                    onPressed: () {
                      newStars = index + 1;
                      setState(() {});
                    },
                  );
                }),
              ),
              TextField(
                controller: editController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Edit your comment',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final newComment = editController.text.trim();
                if (newComment.isNotEmpty && newStars > 0) {
                  await DatabaseHelper.instance
                      .updateRating(reviewId, newStars, newComment);
                  await loadReviews();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (landmarkData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(landmarkData!['Name']),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrls.isNotEmpty)
                CarouselSlider(
                  items: imageUrls
                      .map((url) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white70),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    viewportFraction: 0.9,
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  landmarkData!['Name'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildInfoTitle('Description'),
              buildInfoText(landmarkData!['Description']),
              const SizedBox(height: 16),
              buildInfoTitle('Cost Range'),
              buildInfoText(landmarkData!['Cost Range']),
              const SizedBox(height: 16),
              buildInfoTitle('Opening Hours'),
              buildInfoText(landmarkData!['Opening Hours ']),
              const SizedBox(height: 30),
              buildInfoTitle('Add Your Review'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => selectedStars = index + 1);
                    },
                  );
                }),
              ),
              TextField(
                controller: _commentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: submitReview,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Submit Review'),
              ),
              const SizedBox(height: 30),
              buildInfoTitle('All Reviews'),
              const SizedBox(height: 10),
              ...reviews.map((review) => Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['user_name'] ?? 'Guest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      i < review['stars']
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    )),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review['comment'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      trailing: (currentUserName != null &&
                              currentUserName == review['user_name'])
                          ? IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () => editReview(
                                review['id'],
                                review['comment'],
                                review['stars'],
                              ),
                            )
                          : null,
                    ),
                  )),
              const SizedBox(height: 30),
              buildInfoTitle('Suggested Places'),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final lm = suggestions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LandmarkDetailPage(landmarkId: lm.landmarkId),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.lightBlue,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: CachedNetworkImage(
                                  imageUrl: lm.url,
                                  width: 160,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lm.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lm.location,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
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
        ),
      ),
    );
  }

  Widget buildInfoTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget buildInfoText(String? text) => Text(
        text ?? 'No data available',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      );
}
