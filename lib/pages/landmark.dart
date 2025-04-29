class Landmark {
  final int landmarkId;
  final String category;
  final String name;
  final String location;
  final String url;
  final String description;
  final String costRange;
  final String openingHours;

  Landmark({
    required this.landmarkId,
    required this.category,
    required this.name,
    required this.location,
    required this.url,
    required this.description,
    required this.costRange,
    required this.openingHours,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      landmarkId: json['Landmark_Id'],
      category: json['Category'],
      name: json['Name'],
      location: json['Location'],
      url: json['URL'],
      description: json['Description'],
      costRange: json['Cost Range'],
      openingHours: json['Opening Hours '],
    );
  }
}
