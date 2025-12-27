class Comment {
  final String user;
  final String message;
  final String createdAt;

  Comment({required this.user, required this.message, required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'],
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}
