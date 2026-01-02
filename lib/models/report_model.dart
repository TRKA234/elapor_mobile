class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String lat;
  final String lng;
  final String address;
  final String status;
  final List<String> photoUrls;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final int commentCount;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
    required this.photoUrls,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.commentCount,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['photos'] is String) {
      photos = (json['photos'] as String)
          .split(',')
          .where((p) => p.isNotEmpty)
          .toList();
    } else if (json['photos'] is List) {
      photos = List<String>.from(json['photos']);
    }

    return Report(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Umum',
      lat: json['latitude']?.toString() ?? '0',
      lng: json['longitude']?.toString() ?? '0',
      address: json['address'] ?? 'Lokasi tidak tersedia',
      status: json['status'] ?? 'pending',
      photoUrls: photos,
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? 'Anonim',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      commentCount: json['comment_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      'status': status,
      'photos': photoUrls.join(','),
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'comment_count': commentCount,
    };
  }
}
