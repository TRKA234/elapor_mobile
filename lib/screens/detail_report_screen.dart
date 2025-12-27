import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/report_model.dart';
import '../models/comment_model.dart';
import '../services/api_config.dart';

class DetailReportScreen extends StatefulWidget {
  final Report report;
  DetailReportScreen({required this.report});

  @override
  _DetailReportScreenState createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  List<Comment> comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  // Ambil Komentar dari Node.js (MongoDB)
  Future<void> fetchComments() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.commentUrl}/comments/${widget.report.id}"),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        comments = data.map((c) => Comment.fromJson(c)).toList();
      });
    }
  }

  // Kirim Komentar ke Node.js (MongoDB)
  Future<void> sendComment() async {
    if (_commentController.text.isEmpty) return;
    final url =
        "${ApiConfig.commentUrl}/add-comment?report_id=${widget.report.id}&user=UserMobile&msg=${_commentController.text}";
    await http.get(Uri.parse(url));
    _commentController.clear();
    fetchComments(); // Refresh list komentar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Laporan")),
      body: Column(
        children: [
          ListTile(
            title: Text(
              widget.report.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Text(
              "Lokasi: ${widget.report.lat}, ${widget.report.lng}",
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(child: Text(comments[index].user[0])),
                title: Text(comments[index].user),
                subtitle: Text(comments[index].message),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: "Tambah komentar..."),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: sendComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
