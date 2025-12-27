class Report {
  final String id;
  final String title;
  final String lat;
  final String lng;

  Report({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      title: json['title'],
      lat: json['latitude'].toString(),
      lng: json['longitude'].toString(),
    );
  }
}
