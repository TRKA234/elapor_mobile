import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';
import 'api_config.dart';

class ReportService {
  Future<List<Report>> fetchReports() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.reportUrl}/list.php"),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Report.fromJson(data)).toList();
    } else {
      throw Exception('Gagal mengambil data dari PHP Service');
    }
  }
}
